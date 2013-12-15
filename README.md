salesforce-apex-templates
=========================

APEX Templates provide a simple template engine, similar to the standard Salesforce mail merge one. Its aim is to generate messages and emails directly from APEX, for provided SObjects or maps of values.

Basic usage
-----------

The below snippet demonstrates the most basic usage of APEX Templates:

```javascript
Case someCase = new Case(
  Subject = 'Test Case'
);

// The below will return 'A message for Test Case.'
new Template(
  'A message for {!Case.Subject}.'
).evaluate(someCase);
```
