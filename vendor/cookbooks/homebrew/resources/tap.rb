actions :tap, :untap
attribute :name,
  :name_attribute => true,
  :kind_of        => String,
  :regex          => /\w+(?:\/\w+)+/

attribute :tapped,
  :kind_of => [TrueClass, FalseClass]

### hax for default action
def initialize( *args )
  super
  @action = :tap
end
