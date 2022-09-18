## i3 save layout
I've created this one because I had to manually attach i3 containers to outputs every time I've plugged in my extra monitors.

**It is still work in progress, but seems to be working ok!**

### How it works?
After you build an executable, run:
- `i3-save-layout --save` to save current layout - for example when you have your extra screens plugged in
- `i3-save-layout --load` to load current layout - for example when you unplugged you extra screens before and now you are plugging them in again

### Requirements
You need to install [janet](https://janet-lang.org/) and [jpm](https://janet-lang.org/docs/jpm.html).

### To install dependencies
```
sudo jpm deps
```
### To install
```
sudo jpm install
```
### To run
```
janet main.janet (--load/--save)
```
### To run tests
```
jpm test
```
### To build
```
jpm build
```

### TODO:
- [unit tests](https://github.com/janet-lang/janet/discussions/846)
- github actions
