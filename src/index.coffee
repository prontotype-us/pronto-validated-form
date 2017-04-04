React = require 'react'
classSet = require 'react-classset'
helpers = require './helpers'
validation = require './validation'
ObjectEditor = require 'object-editor'

ValidatedFormMixin =
    resetState: ->
        @setState @getInitialState()

    validate: ->
        helpers.compactObj helpers.mapObjKey @props.fields, (field_name) =>
            @refs[field_name]?.validate()

    # Validate and maybe even submit form
    trySubmit: (e) ->
        e.preventDefault()

        if !@state.loading
            @setState {errors: {}}

            errors = @validate()

            if Object.keys(errors).length > 0
                @setState {errors: errors}

            else
                {values} = @state
                if @props.onSubmit?
                    @props.onSubmit?(values, @onUpdated)
                else if @onSubmit?
                    @onSubmit(values)

    onUpdated: ->
        @setState {changed: false}

    onChange: (key) -> (value) =>
        values = @state.values || {}
        values[key] = value
        @setState {values, changed: true}, =>
            @onChanged?(key, value)

    clear: ->
        @setState {values: {}, errors: {}, changed: false}

    renderFields: ->
        console.log '[ValidatedFormMixin.renderFields] @props =', @props
        console.log '[ValidatedFormMixin.renderFields] @state =', @state

        <div>
            {Object.keys(@props.fields).map (field_name) =>
                @renderField field_name
            }
        </div>

    renderField: (field_name) ->
        field = @props.fields[field_name]

        <ValidatedField {...field}
            ref=field_name
            key=field_name
            name=field_name
            value=@state.values?[field_name]
            values=@state.values
            error=@state.errors?[field_name]
            onChange=@onChange(field_name)
        />

ValidatedField = React.createClass
    getDefaultProps: ->
        type: 'text'

    value: ->
        return @props.value

    validate: ->
        # Don't bother validating optional or hiddenfields
        if @isOptional() or @isHidden()
            return null

        validator = @props.validator || validation['valid_' + @props.type] || validation.exists

        if !validator(@props.value)
            if @props.error_message
                return @props.error_message
            else if !@props.value
                return "Empty #{helpers.unslugify @props.name}"
            else
                return "Invalid #{helpers.unslugify @props.name}"

        return null

    changeValue: (e) ->
        value = if e.target? then e.target.value else e
        @props.onChange(value)

    focus: ->
        @refs.field.focus()

    isOptional: ->
        if typeof @props.optional == 'function'
            return @props.optional(@props.values)

        else if @props.optional
            return true

        return false

    isHidden: ->
        if typeof @props.hidden == 'function'
            return @props.hidden(@props.values)

        else if @props.hidden
            return true

        return false

    render: ->
        if @isHidden()
            return <div className='validated-field-hidden' />

        form_group_class_set =
            'form-group': true
            'has-error': @props.error
            'required': !@isOptional()
        form_group_class_set["#{@props.name}"] = true
        form_group_class_set["#{@props.className}"] = true
        form_group_class = classSet form_group_class_set

        _value = @props.value || ''

        if @props.type == 'phone'
            dashless = _value.replace(/-/g,'')
            if dashless.length == 4
                value = dashless[0..2] + '-' + dashless[3..]
            else if dashless.length == 7
                value = dashless[0..2] + '-' + dashless[3..5] + '-' + dashless[6..]
            else
                value = _value
        else
            value = _value

        <div className=form_group_class>
            {if @props.type not in ['hidden', 'checkbox']
                <label htmlFor=@props.name>
                    {if @props.icon
                        <i className="fa fa-#{@props.icon}" />
                    }
                    <span>{@props.label || helpers.humanize(@props.name)}</span>
                </label>
            }

            {switch @props.type
                when 'toggle'
                    <Toggle options=@props.options onChange=@changeValue selected=@props.value />
                when 'select'
                    <select value=value onChange=@changeValue>
                        <option>{@props.placeholder || 'Select one'}</option>
                        {@props.options.map (o) ->
                            <option key={o.value || o} value={o.value || o}>{o.display || o}</option>
                        }
                    </select>
                when 'textarea'
                    <textarea key=@props.name
                        ref='field'
                        name=@props.name
                        type=@props.type
                        placeholder={@props.placeholder || helpers.humanize(@props.name)}
                        value=value
                        onChange=@changeValue
                        autoComplete=@props.autoComplete
                        autoCorrect=@props.autoCorrect
                    />
                when 'object'
                    <ObjectEditor object={value or {}} onSave=@changeValue />
                when 'checkbox'
                    <Checkbox key=@props.name
                        name=@props.name
                        icon=@props.icon
                        label=@props.label
                    />
                else
                    <input key=@props.name
                        ref='field'
                        name=@props.name
                        type=@props.type
                        placeholder={@props.placeholder || helpers.humanize(@props.name)}
                        value=value
                        onChange=@changeValue
                        autoComplete=@props.autoComplete
                        autoCorrect=@props.autoCorrect
                    />
            }

            {if @props.error
                <span className='error'>{@props.error}</span>
            }
        </div>

ValidatedForm = React.createClass
    mixins: [ValidatedFormMixin]

    getInitialState: ->
        loading: false
        changed: false
        values: @props.values or {}

    render: ->
        <form onSubmit=@trySubmit className='validated-form'>
            {@renderFields()}
            <button disabled={!@state.changed}>
                {if @state.loading
                    "Loading..."
                else
                    "Submit"
                }
            </button>
        </form>

Checkbox = React.createClass
    getInitialState: ->
        checked: false

    toggleCheck: ->
        console.log '[Checkbox.toggleCheck]'
        @setState checked: !@state.checked
        @props.onChange?()

    render: ->
        <div className='checkbox'>
            <input 
                type='checkbox'
                name=@props.name
                checked={@state.checked}
                onChange=@toggleCheck
            />
            <label htmlFor=@props.name>
                {if @props.icon
                    <i className="fa fa-#{@props.icon}" />
                }
                <span>{@props.label || helpers.humanize(@props.name)}</span>
            </label>
        </div>

Toggle = React.createClass
    getInitialState: ->
        selected: @props.selected || ''

    select: (key) -> =>
        @value = key
        @setState selected: key
        @props.onChange?(key)

    selected: (key) ->
        if @state.selected == key
            'selected'
        else
            ''

    render: ->
        <div className='toggle'>
            {@props.options.map @renderOption}
        </div>

    renderOption: (option, i) ->
        <a key=i onClick=@select(option) className=@selected(option)>{option}</a>

module.exports = {
    ValidatedField
    ValidatedFormMixin
    ValidatedForm
}

