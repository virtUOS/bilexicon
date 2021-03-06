class Lemma < ActiveRecord::Base

  has_many :categorizations, :dependent => :delete_all
  has_many :categories, :through => :categorizations

  has_many :examples, :as => :exampleable,
                      :dependent => :destroy,
                      :order => "position"

  has_many :subentries,     :dependent => :destroy, :order => "position", :include => :examples
  has_many :valencies,      :dependent => :destroy, :order => "position", :include => :examples, :extend => GroupedSubentriesExtension
  has_many :collocations,   :dependent => :destroy, :order => "position", :include => :examples, :extend => GroupedSubentriesExtension
  has_many :phraseologisms, :dependent => :destroy, :order => "position", :include => :examples, :extend => GroupedSubentriesExtension

  validates_presence_of :short1, :short2, :long1, :long2,
                        :word_class1, :word_class1,
                        :level_rezeptiv, :level_produktiv


  # define indices for the sphinx search engine
  define_index do
    indexes short1, short2, long1, long2, phonetic1, phonetic2,
            synonym1, synonym2, annotation1, annotation2

    # additional fields dependend on word class
    indexes [singular_genitive1,  singular_genitive2,
             plural1,             plural2,
             female_form1,        female_form2,
             present_tense1,      present_tense2,
             past_tense1,         past_tense2,
             present_participle1, present_participle2,
             past_participle1,    past_participle2,
             comparative1,        comparative2,
             superlative1,        superlative2], :as => :additional_fields

    indexes examples.form1, :as => :examples_form1
    indexes examples.form2, :as => :examples_form2

    indexes subentries.form1, :as => :subentries_form1
    indexes subentries.form2, :as => :subentries_form2
    indexes subentries.synonym1, :as => :subentries_synonym1
    indexes subentries.synonym2, :as => :subentries_synonym2
    indexes subentries.examples.form1, :as => :subentries_examples_form1
    indexes subentries.examples.form2, :as => :subentries_examples_form2

    set_property :delta => true

  end

  GENDERS = %w(m f n)

  LEVELS = %w(A1 A2 B1 B2 C1 C2)


  WORD_CLASSES = [:N, :Npl, :N_and_N, :Nquant, :V, :ADJ, :N_pattern,
                  :ADJ_pattern, :NUM, :ORD, :wh_CL, :that_CL, :wh_to_INF,
                  :REL_CL, :ADV, :ADVtime, :ADVplace, :PREP, :PrepN, :PART,
                  :PRON, :ReflPRON, :SENTENCE]

  def self.word_classes(locale)
    Lemma::WORD_CLASSES.collect do |wc|
      [I18n.translate("word_classes.#{wc}", :locale => locale), wc.to_s]
    end
  end

  include HasAdditionalAttributes

  additional_attributes :N, :gender, :singular_genitive, :plural,
                            :singular_only, :collective, :female_form,
                            :countable, :uncountable

  additional_attributes :V, :auxiliary, :reflexive, :regular, :irregular,
                            :transitive, :intransitive, :present_tense,
                            :past_tense, :present_participle, :past_participle

  additional_attributes_on_side 2, :V, :perfekt_haben, :perfekt_sein,
                                       :partikel_trennbar, :hat_ge

  additional_attributes :ADJ, :comparative, :superlative,
                              :predicative, :attributive


  def level
    "#{level_rezeptiv}/#{level_produktiv}"
  end


  def collocations_grouped_by_meaning
    collocations.inject(Hash.new {|hash, key| hash[key] = []}) do |hash, coll|
      hash[""] << coll if coll.meanings.length == 0;
      coll.meaning_list.each do |m|
        hash[m] << coll
      end
      hash
    end.sort_by {|a, b| -b.length}
  end

  def self.find_without_categorizations
    find(:all, :readonly => false,
         :select => "lemmata.*",
         :joins => "LEFT OUTER JOIN categorizations c ON lemmata.id = c.lemma_id",
         :conditions => "c.id IS NULL")
  end


  protected
    def validate
      errors.add_on_empty(:categories)
    end

end

