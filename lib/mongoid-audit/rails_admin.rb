module RailsAdmin
  module Extensions
    module MongoidAudit
      class VersionProxy
        def initialize(version)
          @version = version
        end

        def message
          @message = @version.action
          mods = @version.modified.to_a.map do |c|
            if c[1].class.name == "Moped::BSON::Binary" || c[1].class.name == "BSON::Binary"
              c[0] + " = {binary data}"
            elsif c[1].to_s.length > 220
              c[0] + " = " + c[1].to_s[0..200]
            else
              c[0] + " = " + c[1].to_s
            end

          end
          @version.respond_to?(:modified) ? @message + ' ' + table +  " [" + mods.join(", ") + "]" : @message
        end

        def created_at
          @version.created_at
        end

        def table
          @version.association_chain.last['name']
        end

        def username
          @version.modifier.try(:email) || @version.modifier
        end

        def item
          @version.association_chain.last['id']
        end
      end

      class AuditingAdapter
        COLUMN_MAPPING = {
            :table => 'association_chain.name',
            :username => 'modifier_id',
            :item => 'association_chain.id',
            :created_at => :created_at,
            :message => :action
        }

        def initialize(controller, version_class = HistoryTracker)
          @controller = controller
          @version_class = version_class.to_s.constantize
        end

        def latest
          @version_class.order_by([:_id, :desc]).limit(20).map { |version| VersionProxy.new(version) }
        end

        def delete_object(object, model, user)
          # do nothing
        end

        def update_object(object, model, user, changes)
          # do nothing
        end

        def create_object(object, abstract_model, user)
          # do nothing
        end

        def listing_for_model(model, query, sort, sort_reverse, all, page, per_page = (RailsAdmin::Config.default_items_per_page || 20))
          history = @version_class.where('association_chain.name' => model.model_name)
          history = history.any_of({action: /.*#{query}.*/}, {modifier_id: /.*#{query}.*/}) if query.present?
          if sort
            order = sort_reverse == "true" ? :desc : :asc
            history = history.order_by(sort.to_sym => order)
          else
            history = history.order_by(created_at: :desc)
          end

          history = all ? history.entries : history.send(Kaminari.config.page_method_name, page.presence || "1").per(per_page)

          history.map{|version| VersionProxy.new(version)}
        end

        def listing_for_object(model, object, query, sort, sort_reverse, all, page, per_page = (RailsAdmin::Config.default_items_per_page || 20))
          history = @version_class.where('association_chain.name' => model.model_name, 'association_chain.id' => object.id)
          history = history.any_of({action: /.*#{query}.*/}, {username: /.*#{query}.*/}) if query.present?
          if sort
            order = sort_reverse == "true" ? :desc : :asc
            history = history.order_by(sort.to_sym => order)
          else
            history = history.order_by(created_at: :desc)
          end
          history = all ? history.entries : history.send(Kaminari.config.page_method_name, page.presence || "1").per(per_page)

          history.map{|version| VersionProxy.new(version)}
        end
      end
    end
  end
end



RailsAdmin.add_extension(:mongoid_audit, RailsAdmin::Extensions::MongoidAudit, {
  :auditing => true
})
