# Infer Color Scheme from CSS file

If you have an extraneous project whose color scheme you want to infer, you can feed its CSS to this handy script.

Put a copy of the file at the `test_css` folder and then

```
./infer.rb test_css/{{filename}}
```

An html file will be generated in the `output` folder with all the colors that appear in the document.
