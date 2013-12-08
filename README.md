salesforce-apex-templates
=========================

Looking for a possibility to use Email Templates within APEX code? Here's the answer!

How to use generic templates?
-----------------------------

```javascript
MergeValues values = new MergeValues();
values.put('someString', 'Some value');
values.put('anotherDate', Date.today());
values.put(new Case(subject = 'Sample case'));
values.put('someMap', new Map<String,Object> {
  'value' => 'map\'s value'
});

Template t = new Template(
	'Here you can use:\n'
	+ '* {!someString} or {!anotherDate},\n'
	+ '* {!Case.subject} or {!someMap.value}\n'
);
t.evaluate(values);
```

Generate emails easily!
-----------------------

```javascript
new EmailGenerator('someTemplate')
  .apply(someCase)
  .getEmailMessage();
```
