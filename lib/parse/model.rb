# -*- encoding : utf-8 -*-
module Parse
  class Model < Parse::Object

    # Override this method if your model name is different from the
    # Parse object name you're using.
    def self.parse_object_name
      return '_User' if self < Parse::User
      self.to_s
    end

    def initialize(data=nil)
      super(self.class.parse_object_name, data)
    end

    def self.find(object_id)
      find_by_object_id(object_id)
    end

    def self.all
      query.get.map { |r| self.new(r) }
    end

    def self.fields(*fields)
      @@parse_fields ||= []
      @@parse_fields.concat(fields.map(&:to_sym)).uniq!
    end

    def self.paginate(*params)
      query.paginate(*params)
    end

    def self.query
      Parse::Query.new(parse_object_name)
    end

    def self.find_by(query_hash)
      self.new self.query.eq(query_hash).first
    end

    def new_record?
      self['objectId'].blank?
    end

    def model_name
      return ActiveModel::Name.new(self.class) if defined?(ActiveModel::Name)
      self.class.parse_object_name.gsub('_','').underscore
    end

    def method_missing(m,*args,&block)
      return self[m.to_s[0..-2]] = args.first if m.to_s.ends_with?('=')
      return self[m.to_s] if self.keys.concat(@@parse_fields || []).include?(m.to_sym)
      super
    end

    def self.method_missing(m, *args, &block)
      if m.to_s.starts_with?('find_by_')
        raise 'unknown find_by signature' unless args.length == 1
        return find_by m.to_s.gsub('find_by_','').camelize(:lower) => args[0]
      end
      super
    end

  end
end
