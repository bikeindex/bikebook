updateManufacturer = (e) ->
  target = $(e.target)
  mnfg = target.parents('.selectors').find('select.manufacturer-select option:selected')
  year = target.parents('.selectors').find('select.year-select')
  if mnfg.val().length != 0
    data = JSON.parse("[#{mnfg.attr('data-years')}]")
    year.html(Mustache.to_html($('#years_tmpl').html(), data))
    year.select2 "enable", true
    year.select2 "val", data[0]
    getModelList(e)
    
  else
    year.select2 "enable", false
    model_list.fadeOut 'fast', ->
      model_list.empty()

getModelList = (e) ->
  target = $(e.target)
  year = target.parents('.selectors').find('select.year-select').val()
  model_list = target.parents('.selectors').find('.model-select-contain')
  mnfg = target.parents('.selectors').find('select.manufacturer-select').val()  
  url = "/?manufacturer=#{mnfg}&year=#{year}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      setModelList(model_list, data)

getBike = (e) ->
  target = $(e.target)
  year = target.parents('.selectors').find('select.year-select').val()
  model = target.parents('.selectors').find('select.model-select').val()
  mnfg = target.parents('.selectors').find('select.manufacturer-select').val()  
  return true unless model.length > 0
  url = "/?manufacturer=#{mnfg}&year=#{year}&frame_model=#{model}"
  $.ajax
    type: "GET"
    url: url
    success: (data, textStatus, jqXHR) ->
      target.parents('section').find('.model-display').fadeOut 200, ->
        updateModelDisplay(target.parents('section'),data)
    
updateModelDisplay = (target, data=[]) ->
  target.find('.model-display').html(Mustache.to_html($('#details_tmpl').html(), data))
  target.find('.model-display').fadeIn()

  fields = ['.bikebase','.frameandfork','.drivetrainandbrakes','.wheels','.additionalparts']
  bike = data["bike"]
 
  if bike['rear_wheel_bsd'] != undefined
    tires = ''
    wheel_sizes = JSON.parse($('#wheel_sizes').attr('data-sizes'))
    desc = wheel_sizes[bike['rear_wheel_bsd']]

    if bike['rear_tire_narrow'] != undefined
      tires = if bike['rear_tire_narrow'] then 'skinny' else 'fat'
      tires = "(#{tires} tires)"

    target.find(".w-size").html("#{desc} #{tires}")
  
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

setModelList = (target, data=[]) ->
  target.html(Mustache.to_html($('#models_tmpl').html(), data))
  target.find('select')
    .select2
      placeholder: "Select model"
  target.fadeIn('fast')
    
addBike = ->
  $.ajax
    type: "GET"
    url: "/assets/select_list.json"
    success: (data, textStatus, jqXHR) ->
      html = $(Mustache.to_html($('#base_tmpl').html(), data))
      $("#bikes-container").append html
      html.find('.manufacturer-select').select2
        placeholder: "Choose manufacturer"
        allow_clear: true
      html.find('.year-select').select2
        placeholder: "Year"
      html.fadeIn()
 
initialize = ->
  addBike()
  $('#new-compare').on 'click', (e) ->
    e.preventDefault()
    addBike()
  
  $('#bikes-container').on 'click', '.close', (e) ->
    e.preventDefault()
    $(e.target).parents('.bike').fadeOut()

  $('#bikes-container').on 'click', '.comp_cat_link', (e) ->
    e.preventDefault()
    $(e.target).parents('.comp_cat_wrap').find('dl').slideToggle 300

  $('#bikes-container').on 'change', 'select.model-select', (e) ->
    getBike(e)

  $('#bikes-container').on 'change', 'select.manufacturer-select', (e) ->
    updateManufacturer(e)

  $('#bikes-container').on 'change', 'select.year-select', (e) ->
    getModelList(e)


$(document).ready ->
  setTimeout ( ->
    $('#initial').addClass('off-screen')
    setTimeout ( ->
      initialize()
      $('#initial').addClass('removed')
      ), 500
    ), 700
  
  