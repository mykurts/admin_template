module KTDatatableAdapter
  # @query: AR queries
  # @pagination: Usually `params[:pagination]` from KTDatatable generated requests
  def self.get_page(query, pagination)
    page = pagination["page"].to_i
    offset_page = page - 1
    offset_page = offset_page <= 0 ? 0 : offset_page
    perpage = pagination["perpage"].to_i
    perpage = perpage <= 0 ? 10 : perpage
    total_items = query.count
    total_pages = (total_items.to_f / perpage.to_f).ceil

    # KTDatatable is retaining pages when changing perpage
    if page > total_pages
      page = 1
      offset_page = 0
    end

    meta = {
      page: page,
      pages: total_pages,
      perpage: perpage,
      total: total_items,
      # TODO: Sorting functionality
      sort: "",
      field: ""
    }

    if query.kind_of?(Array)
      return meta, query.drop(offset_page * perpage).first(perpage)
    end
    
    return meta, query.offset(offset_page * perpage).limit(perpage)
  end
end