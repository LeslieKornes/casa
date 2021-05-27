require "rails_helper"

RSpec.describe "past_court_dates/show", type: :view do
  shared_examples_for "a past court date with all court details" do
    let(:past_court_date) { create(:past_court_date, :with_court_details) }
    let(:case_court_mandate) { past_court_date.case_court_mandates.first }

    it "displays all court details" do
      render template: "past_court_dates/show"

      expect(rendered).to include(past_court_date.judge.name)
      expect(rendered).to include(past_court_date.hearing_type.name)

      expect(rendered).to include(case_court_mandate.mandate_text)
      expect(rendered).to include(case_court_mandate.implementation_status.humanize)
    end
  end
  shared_examples_for "a past court date with no court details" do
    let(:past_court_date) { create(:past_court_date) }

    it "displays all court details" do
      render template: "past_court_dates/show"

      expect(rendered).to include("Judge:")
      expect(rendered).to include("Hearing Type")
      expect(rendered).to include("None")

      expect(rendered).to include("There are no court mandates associated with this past court date.")
    end
  end

  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  before do
    enable_pundit(view, user)

    assign :casa_case, past_court_date.casa_case
    assign :past_court_date, past_court_date

    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "with court details" do
    context "when accessed by a casa admin" do
      let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end

    context "when accessed by a supervisor" do
      let(:user) { build_stubbed(:supervisor, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end

    context "when accessed by a volunteer" do
      let(:user) { build_stubbed(:volunteer, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end
  end

  context "without court details" do
    context "when accessed by an admin" do
      let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end

    context "when accessed by a supervisor" do
      let(:user) { build_stubbed(:supervisor, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end

    context "when accessed by a volunteer" do
      let(:user) { build_stubbed(:volunteer, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end
  end
end
