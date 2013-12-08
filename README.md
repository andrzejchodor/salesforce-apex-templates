salesforce-apex-templates
=========================

Looking for a possibility to use Email Templates within APEX code? Here's the answer!

How to use generic templates?
-----------------------------

```
MergeValues values = new MergeValues(new Map<String,Object>{
  'someString' => 'Some value',
  'anotherDate' => Date.today(),
  'someCase' => new Case(subject = 'Sample case'),
  'someMap' => new Map<String,Object> {
    'value' => 'map\'s value'
  }
});

Template t = new Template(
	'Here you can use:\n'
	+ '* {!someString},\n'
	+ '* {!anotherDate},\n'
	+ '* {!someCase.subject} or {!someMap.value}\n'
);

t.evaluate(values);
```

Generate emails easily!
-----------------------

```
new EmailGenerator('someTemplate')
  .apply(someCase)
  .getEmailMessage();
```
