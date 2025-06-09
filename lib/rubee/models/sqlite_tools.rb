module Rubee
  module SqliteTools
    MAX_RETRIES = 3
    DELAY = 0.1

    class << self
      def with_retry
        retries = 0
        begin
          yield
        rescue Sequel::DatabaseError => e
          if e.cause.is_a?(SQLite3::BusyException) && retries < MAX_RETRIES
            retries += 1
            sleep(DELAY)
            retry
          else
            raise e
          end
        end
      end
    end
  end
end

