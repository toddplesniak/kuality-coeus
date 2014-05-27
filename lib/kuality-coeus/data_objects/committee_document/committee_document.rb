class CommitteeDocumentObject < DataFactory

  include StringFactory
  include Navigation

  attr_reader :description, :committee_id, :document_id, :status, :committee_name,
                :home_unit, :min_members_for_quorum, :maximum_protocols,
                :adv_submission_days, :review_type, :last_updated, :updated_user,
                :initiator, :members, :areas_of_research, :type
  
  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      description:            random_alphanums_plus,
      committee_id:           random_alphanums_plus(15),
      home_unit:              '000001',
      name:                   random_alphanums_plus(60),
      min_members_for_quorum: rand(100).to_s,
      maximum_protocols:      rand(100).to_s,
      adv_submission_days:    rand(365).to_s,
      review_type:            'Full',
      members:                collection('CommitteeMember'),
      areas_of_research:      [],
      schedule:               collection('CommitteeSchedule'),
      save_type:              :save
    }
    @lookup_class=CommitteeLookup
    set_options(defaults.merge(opts))
  end
    
  def create
    visit(CentralAdmin).create_irb_committee
    on Committee do |comm|
      @document_id=comm.document_id
      @doc_header=comm.doc_title
      @initiator=comm.initiator
      @status=comm.status
      @search_key = { committee_id: @committee_id }
      comm.committee_id_field.set @committee_id
      comm.committee_name_field.set @name
      fill_out comm, :description, :home_unit, :min_members_for_quorum,
               :maximum_protocols, :adv_submission_days, :review_type
      comm.send(@save_type)
    end
  end

  def submit
    open_document
    on(Committee).submit
  end

  def view(tab)
    open_document
    on(Committee).send(damballa(tab).to_sym)
  end

  def add_member opts={}
    defaults = {document_id: @document_id}
    open_document
    on(Committee).members
    @members.add defaults.merge(opts)
  end

  # =======
  private
  # =======

  # Nav Aids...


end
    
      