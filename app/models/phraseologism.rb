class Phraseologism < ActiveRecord::Base
  belongs_to :lemma
  has_many :examples, :as => :exampleable

  validates_presence_of :form1, :form2
end