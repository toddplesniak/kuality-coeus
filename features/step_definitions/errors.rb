#----------------------#
# Add to the error message hash in situations that throw uncomplicated errors.
# $current_page makes this possible.
#----------------------#
Then /^an error should appear that says (.*)$/ do |error|
  errors = {'to select a valid unit' => 'Please select a valid Unit.',
            'a key person role is required' => 'Key Person Role is a required field.',
            'the credit split is not a valid percentage' => 'Credit Split is not a valid percentage.',
            'only one PI is allowed' => 'Only one proposal role of Principal Investigator is allowed.',
            'the Award has no PI' => 'There is no Principal Investigator selected. Please enter a Principal Investigator',
            'only one PI is allowed in the Contacts' => 'Only one Principal Investigator is allowed',
            'the IP can not be added because it\'s not fully approved' => 'Cannot add this funding proposal. The associated Development Proposal has "Approval Pending - Submitted" status.',
            'the approval should occur later than the application' => 'Approval Date should be the same or later than Application Date.',
            'not to select other roles alongside aggregator' => 'Do not select other roles when Aggregator is selected.',
            'only one version can be final' => 'Only one Budget Version can be marked "Final".',
            'a revision type must be selected' => 'S2S Revision Type must be selected when Proposal Type is Revision.',
            %|I need to select the 'Other' revision type| => %|The revision 'specify' field is only applicable when the revision type is "Other"|,
            'an original proposal ID is needed'=>'Please provide an original institutional proposal ID that has been previously submitted to Grants.gov for a Change\/Corrected Application.',
            'the prior award number is required'=> %|require the sponsor's prior award number in the "sponsor proposal number."|,
            'sponsor deadline date not entered' => 'Sponsor deadline date has not been entered.',
            'a valid sponsor is required' => 'A valid Sponsor Code (Sponsor) must be selected.',
            'the Account ID may only contain letters or numbers' => 'The Account ID (Account ID) may only consist of letters or digits.',
            'the Award\'s title contains invalid characters' => 'The Award Title (Title) may only consist of visible characters, spaces, or tabs.',
            'the anticipated amount must be equal to or more than obligated' => 'The Anticipated Amount must be greater than or equal to Obligated Amount.',
            'the project period has a typo' => 'Project Period is not formatted correctly.',
            'cost share type is required' => 'Cost Share Type Code is a required field.',
            'the fiscal year is not valid' => 'not found is not a valid date.',
            'the approved equipment can\'t have duplicates' => 'Approved Equipment Vendor, Model and Item must be unique',
            'the invoiced exceeds the obligated amount' => 'Cumulative Invoiced Amount would exceed the Obligated Subaward Amount.',
            'the allowable range for fiscal years' => 'Fiscal Year must be between 1900 and 2499.',
            'the protocol number is required for human subjects' => 'Protocol Number is a required field for Human Subjects/Approved.',
            'human subject cannot have exemptions' => 'Cannot select Exemption # for Human Subjects/Approved',
            'organization id is required' => 'Organization Id is a required field.',
            'organization type is required' => 'Organization Type is a required field.'
  }
  expect($current_page.errors).to include errors[error]
end

Then /^an error requiring at least one unit for the co-investigator is shown$/ do
  $current_page.errors.should include %|At least one Unit is required for #{@proposal.key_personnel.co_investigator.full_name}.|
end

Then /^an error about un-certified personnel is shown$/ do
  $current_page.validation_errors_and_warnings.should include %|The Investigators are not all certified. Please certify #{@proposal.key_personnel[0].first_name} #{@proposal.key_personnel[0].last_name}.|
end

Then /^an error is shown that says (.*)$/ do |error|
  errors = { 'there are duplicate organizations' => 'There is a duplicate organization name.',
             'there is no principal investigator' => 'There is no Principal Investigator selected. Please enter a Principal Investigator.',
             'sponsor deadline date not entered' => 'Sponsor deadline date has not been entered.',
             'a project start date is required for the T&M Document' => 'Project Start Date is required when creating a Time &amp; Money document',
             'there are duplicate cost share lines' => 'A duplicate row has been entered.',
             'the subaward\'s amount can\'t be zero' => 'Approved Subaward amount must be greater than zero.'
  }
  $current_page.validation_errors_and_warnings.should include errors[error]
end

Then /^errors about the missing terms are shown$/ do
  ['Equipment Approval', 'Invention','Prior Approval','Property','Publication',
   'Referenced Document','Rights In Data','Subaward Approval','Travel Restrictions']
  .each { |term| $current_page.validation_errors_and_warnings.should include "There must be at least one #{term} Terms defined." }
end

# TODO: Move to the big step def.
Then /^an error is shown that indicates the lead unit code is invalid$/ do
  expect($current_page.errors).to include('Lead Unit is invalid.')
end

Then /^an error is shown that indicates the user is already an investigator$/ do
  expect($current_page.errors).to include(%|#{@first_name} #{@last_name} already holds Investigator role.|)
end

Then /^errors appear on the Contacts page, saying the credit splits for the PI aren't equal to 100\%$/ do
  @award.view :contacts
  on AwardContacts do |page|
    DocumentUtilities::CREDIT_SPLITS.values.each do |type|
      page.errors.should include "The Project Personnel #{type} Credit Split does not equal 100%"
      page.errors.should include "The Unit #{type} Credit Split for #{@award.key_personnel.principal_investigator.full_name} does not equal 100%"
    end
  end
end

#-----------------------#
# Award                 #
#-----------------------#

Then /^the Award should show an error saying the project start date can't be later than the obligation date$/ do
  $current_page.errors.should include "Award #{@award.id} Project Start Date must be before or equal to Obligation Start Date."
end

Then /^the Award should throw an error saying (.*)/ do |error|
  errors = {
    'they are already in the Award Personnel' => "#{@award.key_personnel.principal_investigator.full_name} is already added to the Award Project Personnel",
    'the Award\'s PI requires at least one unit' => "At least one Unit is required for #{@award.key_personnel.principal_investigator.full_name}"
  }
  $current_page.errors.should include errors[error]
end

Then /^an error should say that the (cost share|F&A rate) percentage can only have 2 decimal places$/ do |type|
  items = {
      'cost share' => [:cost_sharing, :percentage],
      'F&A rate'   => [:fa_rates, :rate]
  }
  $current_page.errors.should include "Invalid value #{@award.send(items[type][0])[0].send(items[type][1])}: at most 2 digits may follow the decimal point."
end

#-----------------------#
# Subaward              #
#-----------------------#
Then /^an error should appear on the Subaward saying the person is already added to the contacts$/ do
  on(Subaward).errors.should include "#{@subaward.contacts[0][:name]} is already added to the Subaward Contacts"
end

#------------------------#
# Institutional Proposal #
#------------------------#

Then /^(errors|an error) should appear warning that the field contents are not valid$/ do |x|
  @errors.each do |err|
    expect($current_page.errors).to include err
  end
end

#------------------------#
# Required Fields        #
#------------------------#
Then /^an error should appear saying the field is required$/ do
  expect($current_page.errors).to include @required_field_error
end

Then /^error messages should appear for the required fields on the Special Review$/ do
  required_fields = ['Type', 'Approval Status']
  required_fields.map! {|req| "#{req} is a required field." }

  required_fields.each do |err|
    expect($current_page.errors).to include err
  end
end


#------------------------#
# Protocols -IRB & IACUC #
#------------------------#
And /^error messages should appear for invalid dates on the Special Review$/ do
  special_review_dates = [:application_date, :approval_date, :expiration_date]
  special_review_dates.map! {|date_type| "#{@special_review.send(date_type)} is not a valid date."}

  special_review_dates.each do |err|
    expect($current_page.errors).to include err
  end
end

Then /^error messages should appear for incorrect date structures on the Special Review$/ do
  errors = [
      'Approval Date should be the same or later than Application Date.',
      'Expiration Date should be the same or later than Approval Date.',
      'Expiration Date should be the same or later than Application Date.'
  ]
  errors.each do |err|
    expect($current_page.errors).to include err
  end
end

#------------------------#
# Miscellaneous          #
#------------------------#
Then /^a confirmation screen asks if you want to edit the existing pending version$/ do
  on(Confirmation).message.should == 'A Pending version already exists. Do you want to edit the Pending version?'
end

Then /^there are no errors on the page$/ do
  expect($current_page.errors.size).to equal(0)
end