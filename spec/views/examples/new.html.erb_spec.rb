require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/examples/new.html.erb" do
  include ExamplesHelper

  before(:each) do
    assigns[:exampleable] = @lemma = stub_model(Lemma)
    assigns[:example] = stub_model(Example,
      :new_record? => true,
      :form1 => "",
      :form2 => "",
      :syntax1 => "",
      :syntax2 => "",
      :synonym1 => "",
      :synonym2 => "",
      :exampleable => @lemma,
      :exampleable_type => "value for exampleable_type"
    )
  end

  it "should render new form" do
    render "/examples/new.html.erb"

    response.should have_tag("form[action=?][method=post]", lemma_examples_path(@lemma)) do
      with_tag("input#example_form1[name=?]", "example[form1]")
      with_tag("input#example_form2[name=?]", "example[form2]")
      with_tag('input#example_syntax1[name=?]', "example[syntax1]")
      with_tag('input#example_syntax2[name=?]', "example[syntax2]")
      with_tag('input#example_synonym1[name=?]', "example[synonym1]")
      with_tag('input#example_synonym2[name=?]', "example[synonym2]")
    end
  end
end

