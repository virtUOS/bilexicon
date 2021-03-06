require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/lemmata/index.html.erb" do
  include LemmataHelper

  describe "after searching without success" do
    before(:each) do
      assigns[:lemmata] = []
      assigns[:lemmata].stub!(:total_pages).and_return(0)
      assigns[:lemmata].stub!(:total_entries).and_return(0)
      params[:q] = "a word that cannot be found"
    end

    it "should render failure message" do
      render "/lemmata/index.html.erb"

      response.should have_tag("h2", :content =>
         /0 #{I18n.translate(:search_results_for)} a word that cannot be found/)
    end
  end

  describe "after successfully searching" do
    before(:each) do
      assigns[:lemmata] = [
        stub_model(Lemma, :short1 => "to be", :short2 => "sein"),
        stub_model(Lemma, :short1 => "or",    :short2 => "oder"),
      ]
      assigns[:lemmata].stub!(:total_pages).and_return(0)
      assigns[:lemmata].stub!(:total_entries).and_return(0)
      params[:q] = "a result"
    end

    it "should render the number of matches" do
      render "/lemmata/index.html.erb"

      response.should have_tag("h2",
        :content => /#{assigns[:lemmata].size} #{I18n.translate(:search_results_for)} a result/)
    end

    it "should render a list of matching" do
      render "/lemmata/index.html.erb"

      response.should have_tag("ul#lemmata") do
        with_tag("li", :count => assigns[:lemmata].size) do
          assigns[:lemmata].each do |lemma|
            with_tag("a[href=?]", lemma_path(lemma), :text => lemma.short1)
            with_tag("a[href=?]", lemma_path(lemma), :text => lemma.short2)
          end
        end
      end

    end
  end
end

