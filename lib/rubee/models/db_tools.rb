module Rubee
  module DBTools
    MAX_RETRIES = Rubee::Configuration.get_db_max_retries || 3
    DELAY = Rubee::Configuration.get_db_retry_delay || 0.1
    BUSY_TIMEOUT = Rubee::Configuration.get_db_busy_timeout || 2000

    class << self
      def with_retry
        retries = 0
        begin
          yield
        rescue Sequel::DatabaseError => e
          # Applicable for msqlite only, however it can be extended in the future
          if Rubee::SequelObject::DB.adapter_scheme == :sqlite &&
              e.cause.is_a?(SQLite3::BusyException) && retries < MAX_RETRIES
            retries += 1
            sleep(DELAY)
            retry
          else
            raise e
          end
        end
      end

      def set_prerequisites!
        # Necessary changes to make sqlite be none blocking
        if Rubee::SequelObject::DB.adapter_scheme == :sqlite
          # WAL mode allows concurrent reads and non-blocking writes.
          Rubee::SequelObject::DB.execute("PRAGMA journal_mode = WAL")
          # Wait 2000ms for a write lock.
          Rubee::SequelObject::DB.execute("PRAGMA busy_timeout = #{BUSY_TIMEOUT}")
        end
      end
    end
  end
end
