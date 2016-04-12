# validated-form

Mixin for creating a form with validated fields. Modeled after react-zamba's ValidatedForm, but implemented as a mixin to simplify custom layout and state.

## Usage

The `ValidatedFormMixin` provides methods for rendering fields, keeping track of fields state, and checking that fields are valid.

### Component requirements

* `fields` An object of field names and options in the shape `{name: options, ...}`. See field options for more information.
* `getInitialState()` Required because a React component does not have state by default. Optionally useful for setting pre-filled values of certain fields.
* `onSubmit(values)` The function to be called if the fields are valid.

### Component methods

* `renderField(name)` Render an individual field with the options in `fields[name]`.
* `trySubmit()` A method that looks through fields
* `clear()` Sets all field values to null


### Component state

* `values` An object of values by field name.

### Field options

* `type` One of text, number, or email (feel free to add more field types).
* `placeholder`A placeholder in case the field name doesn't cut it.

## Example

```coffee
{ValidatedFormMixin} = require 'validated-form'

FormTest = React.createClass
    mixins: [ValidatedFormMixin]

    fields:
        name: {type: 'text'}
        age: {type: 'number'}
        email: {type: 'email'}

    getInitialState: ->
        values:
            name: 'test'

    onSubmit: (values) ->
        @setState {loading: true}
        submitFormAnd =>
            @clear()
            @setState {loading: false}

    render: ->
        <div>
            <form onSubmit=@trySubmit>
                {@renderField 'name'}
                {@renderField 'age'}
                {@renderField 'email'}
                <button>{if @state.loading then "Loading..." else "Submit"}</button>
            </form>
        </div>
```

