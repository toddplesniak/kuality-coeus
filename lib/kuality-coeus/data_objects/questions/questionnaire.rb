class QuestionnaireObject < DataFactory

  include StringFactory

  attr_reader :name, :questions, :module, :module_sub_item_code, :rule_id,
              :mandatory, :label, :version, :id

  def initialize(browser, opts={})
    @browser = browser
    # TODO: Make this more flexible
    # Currently it's only designed to work with existing Questionnaires.
    # It will need to be tweaked to allow for the creation of a new questionnaire.
        opts[:questions] = collection('Questions')
        opts[:qs].each { |q| opts[:questions] << make(QuestionsObject, q) }
        opts.tap { |o| o.delete(:qs) }
        set_options(opts)
        @page_class = Object.const_get(@page_class)
  end

  def create
    # TODO
  end

  def answer_for(person, answer)
    @questions.each { |q|
        q.answer(person, answer, @page_class)
      }
    on(@page_class).save
  end

  def add_question(opts={})
    defaults = {
       category: QUESTION_CATEGORY[@module_sub_item_code]
    }
    @questions.add defaults.merge(opts)
    view
    on Questionnaire do |page|
      page.expand_all
      page.add_question
    end
    on QuestionLookup do |page|
      page.question_id.set @questions.last.question_id
      page.search
      page.check_item @questions.last.question_id
      page.return_selected
    end
    # FIXME: We probably eventually don't want to have a blanket approve here...
    on(Questionnaire).blanket_approve
  end

  def view
    visit Landing
    on Header do |page|
      page.system_admin_portal
      page.use_new_tab
      page.close_parents
    end
    on(Maintenance).questionnaire
    on QuestionnaireLookup do |page|
      page.questionnaire_id.set @id
      page.search
      page.edit_first_item
    end
  end

  PROPOSAL_PERSON_CERT = {
      id: '10001',
      name: 'Proposal Person Certification',
      module: 'Development Proposal',
      module_sub_item_code: 'Proposal Person Certification',
      mandatory: 'Yes',
      label: 'Proposal Person Certification',
      version: '4',
      page_class: 'KeyPersonnel',
      qs: [{ question_id: '10089',
             question: "I certify that I have reviewed this institution's policies and guidelines related to financial conflicts of interest. I understand that if I seek or receive federal funds in support of this project, I have an obligation to adhere to applicable federal regulations and this institution's policy regarding financial conflict of interest.",
             response_type: 'Yes/No',
             category: 'Certifications for Proposal Development'
           },
           { question_id: '10090',
             category: 'Certifications for Proposal Development',
             question: "If the proposal submitted herewith is funded and accepted by this institution, do you agree to conduct the project in accordance with the terms and conditions of the sponsoring agency and the policies of this institution, and will be fully responsible for meeting the requirements of the award, including providing the proper stewardship of sponsored funds, submitting all required technical reports and deliverables on timely basis, and properly disclosing all inventions to the University in accordance with Federal and University policies? Do you certify that the facilities/space and other institutional resources necessary to complete the proposed project are available to the project, or provisions have been arranged with Department/College to make such space or other University resources available in the event an award is made? Do you certify that the proposal submitted herewith is (1) complete in its technical content, (2) adheres to the rules of proper scholarship, including specifically the proper attribution and citation for all text and graphics, (3) complies with federal standards for the integrity of research (e.g., NSF/NIH Misconduct in Science Policy), and (4) is in accordance with specifications established by the sponsoring agency?",
             response: 'Yes'
           }]
  }

  QUESTION_CATEGORY = {
      'Proposal Person Certification' => 'Certifications for Proposal Development'
  }

end