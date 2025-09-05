class Hash

  # ISO does not define Hash#each_pair, so each_pair is defined in gem.
  alias each_pair each


  ##
  # call-seq:
  #     hsh.merge!(other_hash..)                                 -> hsh
  #     hsh.merge!(other_hash..){|key, oldval, newval| block}    -> hsh
  #
  #  Adds the contents of _other_hash_ to _hsh_. If no block is specified,
  #  entries with duplicate keys are overwritten with the values from
  #  _other_hash_, otherwise the value of each duplicate key is determined by
  #  calling the block with the key, its value in _hsh_ and its value in
  #  _other_hash_.
  #
  #     h1 = { "a" => 100, "b" => 200 }
  #     h2 = { "b" => 254, "c" => 300 }
  #     h1.merge!(h2)   #=> {"a"=>100, "b"=>254, "c"=>300}
  #
  #     h1 = { "a" => 100, "b" => 200 }
  #     h2 = { "b" => 254, "c" => 300 }
  #     h1.merge!(h2) { |key, v1, v2| v1 }
  #                     #=> {"a"=>100, "b"=>200, "c"=>300}
  #

  def merge!(*others, &block)
    i = 0; len=others.size
    return self.__merge(*others) unless block
    while i<len
      other = others[i]
      i += 1
      raise TypeError, "Hash required (#{other.class} given)" unless Hash === other
      other.each_key{|k|
        self[k] = (self.has_key?(k))? block.call(k, self[k], other[k]): other[k]
      }
    end
    self
  end

  alias update merge!

  ##
  # call-seq:
  #   hsh.compact!    -> hsh
  #
  # Removes all nil values from the hash. Returns the hash.
  # Returns nil if the hash does not contain nil values.
  #
  #   h = { a: 1, b: false, c: nil }
  #   h.compact!     #=> { a: 1, b: false }
  #

  def compact!
    self.__compact
  end

  ##
  # call-seq:
  #    hsh.compact     -> new_hsh
  #
  # Returns a new hash with the nil values/key pairs removed
  #
  #    h = { a: 1, b: false, c: nil }
  #    h.compact     #=> { a: 1, b: false }
  #    h             #=> { a: 1, b: false, c: nil }
  #
  def compact
    h=self.dup
    h.__compact
    h
  end

  ##
  #  call-seq:
  #     hsh.fetch(key [, default] )       -> obj
  #     hsh.fetch(key) {| key | block }   -> obj
  #
  #  Returns a value from the hash for the given key. If the key can't be
  #  found, there are several options: With no other arguments, it will
  #  raise an `KeyError` exception; if *default* is
  #  given, then that will be returned; if the optional code block is
  #  specified, then that will be run and its result returned.
  #
  #     h = { "a" => 100, "b" => 200 }
  #     h.fetch("a")                            #=> 100
  #     h.fetch("z", "go fish")                 #=> "go fish"
  #     h.fetch("z") { |el| "go fish, #{el}"}   #=> "go fish, z"
  #
  #  The following example shows that an exception is raised if the key
  #  is not found and a default value is not supplied.
  #
  #     h = { "a" => 100, "b" => 200 }
  #     h.fetch("z")
  #
  #  <em>produces:</em>
  #
  #     prog.rb:2:in 'fetch': key not found (KeyError)
  #      from prog.rb:2
  #

  def fetch(key, none=NONE, &block)
    unless self.key?(key)
      if block
        block.call(key)
      elsif !NONE.equal?(none)
        none
      else
        raise KeyError, "Key not found: #{key.inspect}"
      end
    else
      self[key]
    end
  end

  ##
  #  call-seq:
  #     hsh.delete_if {| key, value | block }  -> hsh
  #     hsh.delete_if                          -> an_enumerator
  #
  #  Deletes every key-value pair from *hsh* for which *block*
  #  evaluates to `true`.
  #
  #  If no block is given, an enumerator is returned instead.
  #
  #     h = { "a" => 100, "b" => 200, "c" => 300 }
  #     h.delete_if {|key, value| key >= "b" }   #=> {"a"=>100}
  #

  def delete_if(&block)
    return to_enum :delete_if unless block

    self.each do |k, v|
      self.delete(k) if block.call(k, v)
    end
    self
  end

  ##
  #  call-seq:
  #     hash.flatten -> an_array
  #     hash.flatten(level) -> an_array
  #
  #  Returns a new array that is a one-dimensional flattening of this
  #  hash. That is, for every key or value that is an array, extract
  #  its elements into the new array. Unlike Array#flatten, this
  #  method does not flatten recursively by default. The optional
  #  *level* argument determines the level of recursion to flatten.
  #
  #     a =  {1=> "one", 2 => [2,"two"], 3 => "three"}
  #     a.flatten    # => [1, "one", 2, [2, "two"], 3, "three"]
  #     a.flatten(2) # => [1, "one", 2, 2, "two", 3, "three"]
  #

  def flatten(level=1)
    self.to_a.flatten(level)
  end

  ##
  #  call-seq:
  #     hsh.invert -> new_hash
  #
  #  Returns a new hash created by using *hsh*'s values as keys, and
  #  the keys as values.
  #
  #     h = { "n" => 100, "m" => 100, "y" => 300, "d" => 200, "a" => 0 }
  #     h.invert   #=> {0=>"a", 100=>"m", 200=>"d", 300=>"y"}
  #

  def invert
    h = self.class.new
    self.each {|k, v| h[v] = k }
    h
  end

  ##
  #  call-seq:
  #     hsh.keep_if {| key, value | block }  -> hsh
  #     hsh.keep_if                          -> an_enumerator
  #
  #  Deletes every key-value pair from *hsh* for which *block*
  #  evaluates to false.
  #
  #  If no block is given, an enumerator is returned instead.
  #

  def keep_if(&block)
    return to_enum :keep_if unless block

    self.each do |k, v|
      unless block.call([k, v])
        self.delete(k)
      end
    end
    self
  end


  ##
  #  call-seq:
  #     hsh.to_h     -> hsh or new_hash
  #
  #  Returns `self`. If called on a subclass of Hash, converts
  #  the receiver to a Hash object.
  #
  def to_h
    self
  end

  ##
  #  call-seq:
  #    hash < other -> true or false
  #
  #  Returns `true` if *hash* is subset of
  #  *other*.
  #
  #     h1 = {a:1, b:2}
  #     h2 = {a:1, b:2, c:3}
  #     h1 < h2    #=> true
  #     h2 < h1    #=> false
  #     h1 < h1    #=> false
  #
  def <(hash)
    raise TypeError, "can't convert #{hash.class} to Hash" unless Hash === hash
    size < hash.size and all? {|key, val|
      hash.key?(key) and hash[key] == val
    }
  end

  ##
  #  call-seq:
  #    hash <= other -> true or false
  #
  #  Returns `true` if *hash* is subset of
  #  *other* or equals to *other*.
  #
  #     h1 = {a:1, b:2}
  #     h2 = {a:1, b:2, c:3}
  #     h1 <= h2   #=> true
  #     h2 <= h1   #=> false
  #     h1 <= h1   #=> true
  #
  def <=(hash)
    raise TypeError, "can't convert #{hash.class} to Hash" unless Hash === hash
    size <= hash.size and all? {|key, val|
      hash.key?(key) and hash[key] == val
    }
  end

  ##
  #  call-seq:
  #    hash > other -> true or false
  #
  #  Returns `true` if *other* is subset of
  #  *hash*.
  #
  #     h1 = {a:1, b:2}
  #     h2 = {a:1, b:2, c:3}
  #     h1 > h2    #=> false
  #     h2 > h1    #=> true
  #     h1 > h1    #=> false
  #
  def >(hash)
    raise TypeError, "can't convert #{hash.class} to Hash" unless Hash === hash
    size > hash.size and hash.all? {|key, val|
      key?(key) and self[key] == val
    }
  end

  ##
  #  call-seq:
  #    hash >= other -> true or false
  #
  #  Returns `true` if *other* is subset of
  #  *hash* or equals to *hash*.
  #
  #     h1 = {a:1, b:2}
  #     h2 = {a:1, b:2, c:3}
  #     h1 >= h2   #=> false
  #     h2 >= h1   #=> true
  #     h1 >= h1   #=> true
  #
  def >=(hash)
    raise TypeError, "can't convert #{hash.class} to Hash" unless Hash === hash
    size >= hash.size and hash.all? {|key, val|
      key?(key) and self[key] == val
    }
  end

  ##
  # call-seq:
  #   hsh.dig(key,...)                 -> object
  #
  # Extracts the nested value specified by the sequence of *key*
  # objects by calling `dig` at each step, returning `nil` if any
  # intermediate step is `nil`.
  #
  def dig(idx,*args)
    n = self[idx]
    if args.size > 0
      n&.dig(*args)
    else
      n
    end
  end

  ##
  # call-seq:
  #    hsh.transform_keys {|key| block } -> new_hash
  #    hsh.transform_keys                -> an_enumerator
  #
  # Returns a new hash, with the keys computed from running the block
  # once for each key in the hash, and the values unchanged.
  #
  # If no block is given, an enumerator is returned instead.
  #
  def transform_keys(&block)
    return to_enum :transform_keys unless block
    hash = {}
    self.keys.each do |k|
      new_key = block.call(k)
      hash[new_key] = self[k]
    end
    hash
  end
  ##
  # call-seq:
  #    hsh.transform_keys! {|key| block } -> hsh
  #    hsh.transform_keys!                -> an_enumerator
  #
  # Invokes the given block once for each key in *hsh*, replacing it
  # with the new key returned by the block, and then returns *hsh*.
  #
  # If no block is given, an enumerator is returned instead.
  #
  def transform_keys!(&block)
    return to_enum :transform_keys! unless block
    hash = self.transform_keys(&block)
    self.replace(hash)
    self
  end
  ##
  # call-seq:
  #    hsh.transform_values {|value| block } -> new_hash
  #    hsh.transform_values                  -> an_enumerator
  #
  # Returns a new hash with the results of running the block once for
  # every value.
  # This method does not change the keys.
  #
  # If no block is given, an enumerator is returned instead.
  #
  def transform_values(&b)
    return to_enum :transform_values unless block_given?
    hash = {}
    self.keys.each do |k|
      hash[k] = yield(self[k])
    end
    hash
  end

  ##
  # call-seq:
  #    hsh.transform_values! {|key| block } -> hsh
  #    hsh.transform_values!                -> an_enumerator
  #
  # Invokes the given block once for each value in the hash, replacing
  # with the new value returned by the block, and then returns *hsh*.
  #
  # If no block is given, an enumerator is returned instead.
  #
  def transform_values!(&b)
    return to_enum :transform_values! unless block_given?
    self.keys.each do |k|
      self[k] = yield(self[k])
    end
    self
  end

  def to_proc
    ->x{self[x]}
  end

  ##
  # call-seq:
  #   hsh.fetch_values(key, ...)                 -> array
  #   hsh.fetch_values(key, ...) { |key| block } -> array
  #
  # Returns an array containing the values associated with the given keys
  # but also raises `KeyError` when one of keys can't be found.
  # Also see `Hash#values_at` and `Hash#fetch`.
  #
  #   h = { "cat" => "feline", "dog" => "canine", "cow" => "bovine" }
  #
  #   h.fetch_values("cow", "cat")                   #=> ["bovine", "feline"]
  #   h.fetch_values("cow", "bird")                  # raises KeyError
  #   h.fetch_values("cow", "bird") { |k| k.upcase } #=> ["bovine", "BIRD"]
  #
  def fetch_values(*keys, &block)
    keys.map do |k|
      self.fetch(k, &block)
    end
  end

  alias filter select
  alias filter! select!
end
