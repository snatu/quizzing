module Contexts
  module OrganizationContexts
    
    def create_organizations
      @org1 = FactoryGirl.create(:org)
      sleep 1
      @org2 = FactoryGirl.create(:org, name: "Org Two", primary_contact: 2)
      sleep 1
      @org_inactive = FactoryGirl.create(:org, name: "Org Inactive", active: false)
    end
    
    def destroy_organizations
      @org1.destroy
      @org2.destroy
      @org_inactive.destroy
    end

  end
end