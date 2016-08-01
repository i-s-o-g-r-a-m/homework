/* global document */


(function () {
    'use strict';

    var util = {
        strIsPositiveInt: function(str) {
            return /^\+?[1-9]\d*$/.test(str);
        },

        countPrevSiblings: function f(element, count) {
            count = count ? count : 0;
            var prevElement = element.previousElementSibling;
            if (prevElement) {
                return f(prevElement, count + 1);
            }
            return count;
        }
    };

    var household = {
        // it's not great to muddle together the model and the view here, but
        // it seems like it'd be overkill to implement something more mvc-like

        container: document.getElementsByClassName('household')[0],

        members: [],

        addMember: function(data) {
            this.members.push(data);
            this.container.insertAdjacentHTML('beforeend', this._memberHtml(data));
        },

        removeMember: function(element) {
            var idx = util.countPrevSiblings(element);
            element.parentNode.removeChild(element);
            this.members.splice(idx, 1);
        },

        _memberHtml: function(data) { // would prefer some kind of templating here
            var removeButton = (
                '<button style="margin-left: .5em;" ' +
                'class="remove-member">remove</button>'
            );
            return (
                '<li class="household-member">' +
                    data.relationship +
                    ' / age ' + data.age +
                    ' / ' + (data.smoker ? 'smoker' : 'non-smoker') +
                    removeButton +
                '</li>'
            );
        }
    };

    var FormValidator = function(form) {
        this.form = form;
        this.errorMsgClass = 'error-msg';
    };

    FormValidator.prototype = {
        constructor: FormValidator,

        addErrorMsg: function(element, msg) {
            // doing inline styles here b/c I didn't want to modify the index.html
            var cls = this.errorMsgClass;
            var style = 'padding-left: .5em; display: inline-block; color: red;';
            element.parentNode.insertAdjacentHTML(
                'afterend',
                '<div class="' + cls + '" style="' + style + '">' + msg + '</div>'
            );
        },

        clearErrorMsgs: function() {
            var elements = document.getElementsByClassName(this.errorMsgClass);
            while (elements[0]) {
                elements[0].parentNode.removeChild(elements[0]);
            }
        },

        extractData: function(formInputs) {
            return {
                age: parseInt(formInputs.age.value.trim(), 10),
                relationship: formInputs.relationship.value.trim(),
                smoker: formInputs.smoker.checked
            };
        },

        getInputs: function() {
            return {
                age: this.form.querySelector('input[name="age"]'),
                relationship: this.form.querySelector('select[name="rel"]'),
                smoker: this.form.querySelector('input[name="smoker"]')
            };
        },

        validate: function() {
            var errors = [];
            var inputs = this.getInputs();
            var age = inputs.age.value.trim();
            var relationship = inputs.relationship.value.trim();

            this.clearErrorMsgs();

            if (!age) {
                errors.push([inputs.age, 'age is required']);
            }
            else if (!util.strIsPositiveInt(age)) {
                errors.push([inputs.age, 'age must be a number greater than 0']);
            }

            if (relationship === '') { 
                errors.push([inputs.relationship, 'relationship is required']);
            }

            errors.forEach(function(e) { this.addErrorMsg(e[0], e[1]); }, this);
            return {
                hasErrors: !!errors.length,
                data: errors.length ? {} : this.extractData(inputs)
            };
        }
    };

    var attachEventListeners = (function() {
        var form = document.getElementsByTagName('form')[0];

        var addToHousehold = function() {
            var formValidator = new FormValidator(form);
            var validation = formValidator.validate();
            if (!validation.hasErrors) {
                household.addMember(validation.data);
                form.reset();
            }
        };

        var removeFromHousehold = function() {
            household.removeMember(this);
        };

        var formSubmit = function(event) {
            event.preventDefault();
        };

        var serialize = function() {
            if (!household.members.length) {
                return alert('The household must have at least one member.');
            }

            var element = document.getElementsByClassName('debug')[0];
            var serialized = JSON.stringify(household.members);
            if (!element.childNodes.length) {
                element.appendChild(document.createTextNode(''));
            }
            element.childNodes[0].nodeValue = serialized;
        };

        return function() {
            var addButton = document.querySelector('button[class="add"]');
            var submitButton = document.querySelector('button[type="submit"]');

            addButton.addEventListener('click', addToHousehold, false);
            submitButton.addEventListener('click', serialize, false);
            form.addEventListener('submit', formSubmit, false);

            document.getElementsByClassName('household')[0].addEventListener(
                'click',
                function(event) {
                    var element = event.target;
                    if (element.className === 'remove-member') {
                        removeFromHousehold.call(element.parentNode);
                    }
                }
            );
        };
    }());

    window.onload = function () {
        attachEventListeners();
    };

}());
