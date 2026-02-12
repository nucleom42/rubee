module Rubee
  class AssocArray < Array
    include Rubee::Hookable

    before :map, :each, :select, :to_a, :reject, :each_with_object, :each_with_index, :all?, :empty?,
      :find, :find_all, :find_index, :find_last, :find_last_index, :include?, :any?, :none?, :one?, :memeber?,
      :sum, :group_by, :filter, :collect, :filter_map, :min, :max, :min_by, :max_by, :sort, :sort_by,
      :inspect, :to_json, :last, :first, :count, :fill_array

    def initialize(*args, model, query_dataset, **options)
      super(*args)
      @__model = model
      @__query_dataset = query_dataset
      @__pagination_meta = options[:pagination_meta]
    end

    def all
      @__model.all(__query_dataset: @__query_dataset)
    end

    def where(*args)
      @__model.where(*args, __query_dataset: @__query_dataset)
    end

    def order(*args)
      @__model.order(*args, __query_dataset: @__query_dataset)
    end

    def join(*args)
      @__model.join(*args, __query_dataset: @__query_dataset)
    end

    def limit(*args)
      @__model.limit(*args, __query_dataset: @__query_dataset)
    end

    def offset(*args)
      @__model.offset(*args, __query_dataset: @__query_dataset)
    end

    def paginate(*args)
      total_count = @__query_dataset.count
      current_page, per_page = args
      __pagination_meta = {
        current_page:,
        per_page:,
        total_count:,
        first_page?: current_page == 1,
        last_page?: current_page == (total_count / per_page.to_f).ceil,
        prev: current_page > 1 ? current_page - 1 : nil,
        next: current_page < (total_count / per_page.to_f).ceil ? current_page + 1 : nil,
      }

      @__model.paginate(*args, __query_dataset: @__query_dataset, __pagination_meta:)
    end

    def pagination_meta
      @__pagination_meta
    end

    def ^
      @__query_dataset
    end

    private

    def fill_array
      if @__query_dataset && @__model
        replace @__model.serialize(@__query_dataset)
      end
    end
  end
end
