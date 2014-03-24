resetContainerCount = ->
  # This is so that we know how many bikes are on the screen. It only matters if there are 1, 2 or 3
  # for styling (and on smaller screens, it may not matter how many there are)
  bc = $('#bikes-container .bike').length
  if bc == 0
    addBikeContainer()
    $("#bikes-container").removeClass().addClass("showing-1-bikes")
  if bc < 3 
    $("#bikes-container").removeClass().addClass("showing-#{bc}-bikes")
  if bc > 2
    $("#bikes-container").removeClass().addClass('showing-many-bikes')

collapseToggle = (e) ->
  target = $(e.target)
  target.parents('.comp_cat_wrap').find('dl').slideToggle 300
  target.parents('.comp_cat_wrap').toggleClass('closed')
  closed = []
  section = target.parents('.model-display')
  for cat in section.find('.comp_cat_wrap')
    if section.find(cat).hasClass('closed')
      closed.push(section.find(cat).attr('data-cat'))  
  $("#collapsed-cats").data('collapsed', closed)

urlParam = (name) ->
  url = window.location.href
  results = new RegExp("[\\?&]" + name + "=([^&#]*)").exec(url)
  return 0  unless results
  results[1] or 0
  
initialBike = ->
  # For direct links to bikes, we check query for s_ prefixed things
  bike =
    manufacturer: urlParam('s_manufacturer')
    year: urlParam('s_year')
    frame_model: urlParam('s_frame_model')

showNotFound = (target, bike) ->
  bike.manufacturer = target.find("select.manufacturer-select option[value=#{bike.manufacturer}]").text()
  if target.find('h3 strong').length > 0
    bike.frame_model = target.find('h3 strong').text()
  error = $(Mustache.to_html($('#errors_tmpl').html(), bike))
  target.find('.selectors').append(error)
  error.fadeIn()
  setTimeout ( ->
    error.fadeOut()
    ), 4000

getAndSetManufacturerList = ->
  $.ajax
    type: "GET"
    url: "/assets/select_list.json"
    success: (data, textStatus, jqXHR) ->
      $('#base_tmpl').html($(Mustache.to_html($('#base_tmpl').html(), data)))
      # After we've successfully updated the base template with the select box of mnfgs
      # we call addBikeContainer with the params that the page has
      addBikeContainer(initialBike())

getModelList = (target, bike={}) ->
  bike = targetBike(target) unless bike.year? && bike.manufacturer?
  url = "/?manufacturer=#{bike.manufacturer}&year=#{bike.year}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      setModelList(target, data, bike)

getFrameModel = (target,bike={}) ->
  bike = targetBike(target) unless bike.frame_model?
  return null unless bike.frame_model? && bike.frame_model.length > 0
  url = "/?manufacturer=#{bike.manufacturer}&year=#{bike.year}&frame_model=#{bike.frame_model}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      target.find('.model-display').fadeOut 200, ->
        updateModelDisplay(target,data)
      # Set the share link
      url = "#{window.location.protocol}//#{window.location.host}?s_manufacturer=#{bike.manufacturer}&s_year=#{bike.year}&s_frame_model=#{bike.frame_model}"
      target.find('.share-bike a').attr('href',url)
      target.find('.share-bike input').val(url)
      target.find('.share-bike').fadeIn()
      # Set the data attributes on the target, so that when copying to a new bike, 
      # it pulls the current displayed bike rather than selection.

      target.data('bike', bike)
    error: (data) ->
      showNotFound(target, bike)

setModelList = (target, data, bike={}) ->
  return null unless data?
  bike = targetBike(target) unless bike.frame_model?
  model_select = target.find('.model-select-contain')
  model_select.empty().html(Mustache.to_html($('#models_tmpl').html(), data))
  model_select.find('select.model-select').val(bike.frame_model)
  model_select.find('select').select2
      placeholder: "Select model"
      allow_clear: true
      escapeMarkup: (m) ->
        m  # We're escaping markup because we're using HTML to display msrp
  model_select.fadeIn('fast')
  getFrameModel(target,bike)

updateYear = (target,bike={}) ->
  mnfg = target.find('select.manufacturer-select option:selected')
  year = target.find('select.year-select')
  bike = targetBike(target) unless bike.manufacturer?
  if bike.manufacturer? && bike.manufacturer.length > 0
    data = JSON.parse("[#{mnfg.attr('data-years')}]")
    year.html(Mustache.to_html($('#years_tmpl').html(), data))
    year.select2 "enable", true
    if bike.year? && bike.year.length > 3
      s_year = bike.year 
    else
      s_year = data[0]
      bike.year = s_year
    year.select2 "val", s_year
    getModelList(target, bike)

  else
    year.select2 "enable", false
    target.find('.model-select-contain').fadeOut 'fast', ->
      target.find('.model-select-contain').empty()

updateModelDisplay = (target, data=[]) ->
  target.find('.model-display').html(Mustache.to_html($('#details_tmpl').html(), data))
  target.find('.model-display').fadeIn()

  fields = ['.bike-base','.frameandfork','.drivetrainandbrakes','.wheels','.additionalparts']
  bike = data["bike"]
 
  if bike['rear_wheel_bsd'] != undefined
    tires = ''
    wheel_sizes = JSON.parse($('#wheel_sizes').attr('data-sizes'))
    desc = wheel_sizes[bike['rear_wheel_bsd']]

    if bike['rear_tire_narrow'] != undefined
      tires = if bike['rear_tire_narrow'] == 'true' then 'skinny' else 'fat'
      tires = "(#{tires} tires)"
    target.find(".w-size").html("#{desc} #{tires}")
  else
    target.find(".dt-w-size, .w-size").hide()
  
  for comp in data["components"]
    name = comp["component_type"].replace(/_/g, ' ')
    if comp["front_or_rear"] == "both"
      name += "s"
    else if comp["front_or_rear"] == "front"
      name = "front #{name}"
    else if comp["front_or_rear"] == "rear"
      name = "rear #{name}"
    dlgroup = comp["cgroup"].replace(/\s+/g,'').toLowerCase()
    c = "<dt>#{name}</dt><dd>#{comp["description"]}</dd>"
    target.find(".#{dlgroup} dl").append(c)
  for field in fields
    if target.find("#{field} dd").length == 0
      target.find("#{field}").fadeOut('fast')

  groups = $("#collapsed-cats").data('collapsed')
  if groups.length > 0
    for closed in groups
      target.find(closed).toggleClass('closed').find('dl').hide()

addBikeContainer = (bike={}) ->
  # This is called with bike when:
  # initialBike (called from getAndSetManufacturerList)
  # or copying bike (when there is already a bike and a new bike is added)
  # We append to staging so we can edit it without event handlers
  $('#base_tmpl .bike').clone().appendTo('#staging')
  target = $('#staging .bike')

  target.find('.manufacturer-select').val(bike.manufacturer) if bike.manufacturer?
  $("#bikes-container").append target
  resetContainerCount()
  # Then attach select2 handlers
  target.find('.manufacturer-select').select2
    placeholder: "Choose manufacturer"
    allow_clear: true
  target.find('.year-select').select2
    placeholder: "Year"
    allow_clear: true  
  target.fadeIn()
  # after it's appended, update the year
  # updateYear(target,bike) if bike.manufacturer?
  updateYear(target,bike)
    

targetBike = (target) ->
  bike = 
    manufacturer: target.find('select.manufacturer-select').val()
    year: target.find('select.year-select').val()
    frame_model: target.find('select.model-select').val()

fillInBike = (target,bike) ->
  # Here, if a bike container is added and bike attributes are passed, we put them on the 
  # data attribute of the bike container, so that we can continue to access them.
  target.data('bike',bike)
  target.find('select.manufacturer-select').val(bike.manufacturer).trigger('change')
  
initialize = ->
  getAndSetManufacturerList()

  $('#new-compare').on 'click', (e) ->
    e.preventDefault()
    if $('#bikes-container .bike').length > 0
      if $('#bikes-container .bike').last().data('bike')
        # If there is bike data on the last bike, use it.
        addBikeContainer($('#bikes-container .bike').last().data('bike'))
      else
        # Otherwise, use whatever's selected
        addBikeContainer(targetBike($('#bikes-container .bike').last()))
    else
      addBikeContainer()
  
  $('#bikes-container').on 'click', '.close', (e) ->
    e.preventDefault()
    $(e.target).parents('.bike').fadeOut 300, ->
      $(e.target).parents('.bike').remove()
      resetContainerCount()

  $('#bikes-container').on 'click', '.comp_cat_link', (e) ->
    e.preventDefault()
    collapseToggle($(e.target))

  $('#bikes-container').on 'click', '.comp_cat_link', (e) ->
    e.preventDefault()
    collapseToggle(e)

  $('#bikes-container').on 'change', 'select.manufacturer-select', (e) ->
    target = $(e.target).parents('.bike')
    target.find('select.model-select').val("")
    updateYear(target)

  $('#bikes-container').on 'change', 'select.year-select', (e) ->
    getModelList($(e.target).parents('.bike'))

  $('#bikes-container').on 'change', 'select.model-select', (e) ->
    getFrameModel($(e.target).parents('.bike'))

$(document).ready ->
  $('#bikes-container').css('min-height',"#{$(window).height()*.75}px")
  setTimeout ( ->
    $('#initial').addClass('off-screen')
    initialize()
    setTimeout ( ->
      $('#initial').addClass('removed')
      ), 500
    ), 700
