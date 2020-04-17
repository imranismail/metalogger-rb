module Metalogger
  class Meta
    THREAD_NAMESPACE = :_metalogger_meta.freeze

    def self.instance
      Thread.current[THREAD_NAMESPACE] ||= new
    end

    def self.add(*args)
      self.instance.add(*args)
    end

    def self.remove(*args)
      self.instance.remove(*args)
    end

    def self.reset(*args)
      self.instance.reset(*args)
    end

    def self.snapshot(*args)
      self.instance.snapshot(*args)
    end

    def self.with(*args, &block)
      self.instance.with(*args, &block)
    end

    def add(*objects)
      objects.each do |object|
        hash.merge!(object.to_hash)
      end
      expire
      self
    end

    def remove(*keys)
      keys.each do |key|
        hash.delete(key)
      end
      expire
      self
    end

    def reset
      hash.clear
      expire
      self
    end

    def replace(hash)
      @hash = hash
      expire
      self
    end

    def snapshot
      @snapshot ||= hash.clone
    end

    def with(*objects)
      current = hash.clone

      begin
        add(*objects)
        yield
      ensure
        replace(current)
      end
    end

    private

    def expire
      @snapshot = nil
    end

    def hash
      @hash ||= initial_hash
    end

    def initial_hash
      {pid: $$}
    end
  end
end
