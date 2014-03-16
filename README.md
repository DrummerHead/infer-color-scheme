# Infer Color Scheme from CSS file

*Work in progress*
![Under Construction](http://www.picgifs.com/graphics/w/work-in-progress/graphics-work-in-progress-322888.gif)

If you have an extraneous project whose color scheme you want to infer, you can feed its CSS to this handy script.

Put a copy of the file at the `test_css` folder and then

```
./infer.rb test_css/{{filename}}
```

An html file will be generated in the `output` folder associating the colors used with the declarations that invoke them.
