# coding: UTF-8
module Navigation

  include Utilities

  # NOTE: This module is being phased out.
  #
  # DO NOT USE! Refactor any code that is using this.

  def open_document
    navigate unless on_document?
  end

  def navigate
    on(BasePage).close_extra_windows
    if @lookup_class == DocumentSearch
      if on(Header).doc_search_element.present?
        on(Header).doc_search
      else #you are on old ui and navigate to doc search this way
        visit(Researcher).doc_search
      end

    else
      visit @lookup_class
    end
    on @lookup_class do |page|
      page.send(@search_key.keys[0]).set @search_key.values[0]
      page.search
      # This rescue is a sad necessity, due to
      # Coeus's poor implementation of the Lookup pages
      # in conjunction with user Roles.
      begin
        page.results_table.wait_until_present(5)
      rescue Watir::Wait::TimeoutError
        if on(Header).doc_search_element.present?

          on(Header).doc_search
        else #you are on old ui and navigate to doc search this way
          visit(Researcher).doc_search
          end
        on DocumentSearch do |search|
          search.document_id.set @document_id
          search.search
          search.open_doc @document_id
        end
        return
      end
      if @lookup_class==DocumentSearch
        page.open_doc @search_key.values[0]
      else
        page.medusa
      end
    end
    # Must update the document id, now:
    @document_id=on(DocumentHeader).document_id
  end

  def on_document?
    begin
      on(DocumentHeader).document_id==@document_id && @browser.frm.div(id: 'headerarea').h1.text.strip==@doc_header
    rescue Watir::Exception::UnknownObjectException, Selenium::WebDriver::Error::StaleElementReferenceError, WatirNokogiri::Exception::UnknownObjectException, Watir::Wait::TimeoutError
      false
    end
  end

  def on_page? element
    begin
      element.exist?
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    end
  end

  # Use this if the confirmation dialog may appear.
  # For example: due to missing rates...
  def confirmation(answer='yes')
    begin
      on(Confirmation) do |conf|
        conf.send(answer) if conf.yes_button.present?
      end
    rescue
      # do nothing because the dialog isn't there
    end
  end

end