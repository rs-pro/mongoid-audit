module RailsAdmin
  module Extensions
    module MongoidAudit
      class VersionProxy
        def initialize(version)
          @version = version
        end

        def message
          @message = @version.action
          if @message == 'create'
            return 'new'
          end
          if @message == 'destroy'
            return 'delete'
          end
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
          if @version.association_chain.length == 1
            @version.association_chain.last['name']
          else
            index = 0
            assoc = @version.association_chain
            while !assoc[index+1].nil?
              table = assoc[index]['name'].constantize.relations[assoc[index+1]['name']].class_name
              index += 1
            end
            table
          end
        rescue Exception => e
          puts "mongoid-audit error: #{e.message}"
          nil
        end

        def username
          @version.updater.try(:email) || @version.updater
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

        def latest(include_empty_modifier = false)
          versions = @version_class
          unless include_empty_modifier
            versions.where(:updater_id.exists => true)
          end
          versions = versions.desc(:_id).limit(20)
          versions.map { |version| VersionProxy.new(version) }
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
          listing_for_model_or_object(model, nil, query, sort, sort_reverse, all, page, per_page)
        end

        def listing_for_object(model, object, query, sort, sort_reverse, all, page, per_page = (RailsAdmin::Config.default_items_per_page || 20))
          listing_for_model_or_object(model, object, query, sort, sort_reverse, all, page, per_page)
        end

        protected
          def listing_for_model_or_object(model, object, query, sort, sort_reverse, all, page, per_page)
            if sort.present?
              sort = COLUMN_MAPPING[sort.to_sym]
            else
              sort = :created_at
              sort_reverse = 'true'
            end
            model_name = model.model.name
            if object
              versions = @version_class.where('association_chain.name' => model.model_name, 'association_chain.id' => object.id)
            else
              versions = @version_class.where('association_chain.name' => model_name)
            end
            versions = versions.order_by([sort, sort_reverse == 'true' ? :desc : :asc])
            unless all
              page = 1 if page.nil?
              versions = versions.send(Kaminari.config.page_method_name, page).per(per_page)
            end
            versions.map { |version| VersionProxy.new(version) }
          end
      end
    end
  end
end

RailsAdmin.add_extension(:mongoid_audit, RailsAdmin::Extensions::MongoidAudit, {
  :auditing => true
})

