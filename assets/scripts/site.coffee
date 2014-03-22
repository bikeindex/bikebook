resetContainerCount = ->
  # This is so that we know how many bikes are on the screen. It only matters if there are 1, 2 or 3
  # for styling (and on smaller screens, it may not matter how many there are)
  bc = $('#bikes-container .bike').length
  if bc == 0
    addBikeContainer()
  if bc < 3 
    $("#bikes-container").removeClass().addClass("showing-#{bc}-bikes")
  if bc > 2
    $("#bikes-container").removeClass().addClass('showing-many-bikes')


collapseToggle = (target) ->
  target.parents('.comp_cat_wrap').find('dl').slideToggle 300
  target.parents('.comp_cat_wrap').toggleClass('closed')
  closed = []
  section = target.parents('.model-display')
  for cat in section.find('.comp_cat_wrap')
    if section.find(cat).hasClass('closed')
      closed.push(section.find(cat).attr('data-cat'))  
  $("#collapsed-cats").data('collapsed', closed)

updateManufacturer = (target) ->
  bike = targetBike(target)
  year = target.find('select.year-select')
  if bike.manufacturer? && bike.manufacturer.length > 0
    mnfg = target.find('select.manufacturer-select option:selected')
    data = JSON.parse("[#{mnfg.attr('data-years')}]")
    year.html(Mustache.to_html($('#years_tmpl').html(), data))
    year.select2 "enable", true
    if bike.year?
      year.select2 "val", bike.year 
    else
      year.select2 "val", data[0]
    getModelList(target)
  else
    year.select2 "enable", false
    target.find('.model-select-contain').fadeOut 'fast', ->
      target.find('.model-select-contain').empty()

getModelList = (target) ->
  bike = targetBike(target)
  url = "/?manufacturer=#{bike.manufacturer}&year=#{bike.year}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      setModelList(target, data)

getFrameModel = (target) ->
  bike = targetBike(target)
  return null unless bike.frame_model? && bike.frame_model.length > 0
  url = "/?manufacturer=#{bike.manufacturer}&year=#{bike.year}&frame_model=#{bike.frame_model}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      target.find('.model-display').fadeOut 200, ->
        updateModelDisplay(target,data)
        target.data('bike','') # Erase bike data, since we don't need it anymore.
    
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

  bike = targetBike(target)
  url = "http://bikebook.io/?s_manufacturer=#{bike.manufacturer}&s_year=#{bike.year}&s_frame_model=#{bike.frame_model}"
  link = target.find('.share-bike').attr('href',url)
  

  groups = $("#collapsed-cats").data('collapsed')
  if groups.length > 0
    for closed in groups
      target.find(closed).toggleClass('closed').find('dl').hide()

setModelList = (target, data=[]) ->
  model_select = target.find('.model-select-contain')
  model_select.empty().html(Mustache.to_html($('#models_tmpl').html(), data))
  model_select.find('select').select2
      placeholder: "Select model"
      allow_clear: true
      escapeMarkup: (m) ->
        m  # We're escaping markup because we're using HTML to display msrp
  model_select.fadeIn('fast')
  bike = targetBike(target)
  if bike.frame_model?
    target.find('select.model-select').val(bike.frame_model).trigger('change')
    
addBikeContainer = (bike={}) ->
  # Call with bike for initializations: initial bike or copying bike
  $.ajax
    type: "GET"
    url: "/assets/select_list.json"
    success: (data, textStatus, jqXHR) ->
      html = $(Mustache.to_html($('#base_tmpl').html(), data))
      $("#bikes-container").append html
      resetContainerCount()
      html.find('.manufacturer-select').select2
        placeholder: "Choose manufacturer"
        allow_clear: true
      html.find('.year-select').select2
        placeholder: "Year"
      html.fadeIn()
      fillInBike(html,bike) if bike?
       

urlParam = (name) ->
  url = window.location.href
  results = new RegExp("[\\?&]" + name + "=([^&#]*)").exec(url)
  return 0  unless results
  results[1] or 0
  
intitialBike = ->
  bike =
    manufacturer: urlParam('s_manufacturer')
    year: urlParam('s_year')
    frame_model: urlParam('s_frame_model')

targetBike = (target) ->
  bike = target.data('bike')
  unless bike? && bike.frame_model?
    # If we don't have a complete bike we're not going to load it. Because right 
    # now we're only deleting the bike attributes when a complete bike is created 
    # and so we want to ensure that we're actually going to manage to get there, so 
    # we don't have random bike info sticking around.
    bike = 
      manufacturer: target.find('select.manufacturer-select').val()
      year: target.find('select.year-select').val()
      frame_model: target.find('select.model-select').val()
  bike 

fillInBike = (target,bike) ->
  # Here, if a bike container is added and bike attributes are passed, we put them on the 
  # data attribute of the bike container, so that we can continue to access them.
  target.data('bike',bike)
  target.find('select.manufacturer-select').val(bike.manufacturer).trigger('change')
  
initialize = ->
  addBikeContainer(intitialBike())
  $('#new-compare').on 'click', (e) ->
    e.preventDefault()
    addBikeContainer(targetBike($('#bikes-container .bike').last()))
  
  $('#bikes-container').on 'click', '.close', (e) ->
    e.preventDefault()
    $(e.target).parents('.bike').fadeOut 300, ->
      $(e.target).parents('.bike').remove()
      resetContainerCount()

  $('#bikes-container').on 'click', '.comp_cat_link', (e) ->
    e.preventDefault()
    collapseToggle($(e.target))

  $('#bikes-container').on 'change', 'select.model-select', (e) ->
    target = $(e.target).parents('.bike')
    getFrameModel(target)

  $('#bikes-container').on 'change', 'select.manufacturer-select', (e) ->
    updateManufacturer($(e.target).parents('.bike'))

  $('#bikes-container').on 'change', 'select.year-select', (e) ->

    getModelList($(e.target).parents('.bike'))


$(document).ready ->
  $('#bikes-container').css('min-height',"#{$(window).height()*.75}px")
  setTimeout ( ->
    $('#initial').addClass('off-screen')
    initialize()
    setTimeout ( ->
      $('#initial').addClass('removed')
      ), 500
    ), 700