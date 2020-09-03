# Tizen GBS builder

Tizen GBS build tool.

#### Options
| Name       	 | Description                                              | Mandatory | Type     | Default  |
|------------- |--------------------------------------------------------- |---------- |--------- |--------- |
| gbs_conf     | Configuration file (gbs.conf) location                  	| O         | String   |          |
| debug        | debug output                                            	|           | Boolean  | false    |
| verbose      | verbose output       	                                   |           | Boolean  | false    |
| profile      | Profile to be used for build (string from gbs.conf)     	| O         |          |          |
| architecture | Target architecture to build.                            | O         |          |          |
| define_macro | Macros       	                                           |           | String   | ""       |
| build_conf   | Project build configuration file                       	 |           | String   | ""       |
| baselibs     | Create -32bit/-64bit/-x86 rpms for other architectures  	|           | String   | ""       |
| clean        | Delete old build root before initialization             	|           | Boolean  | false    |
| clean_once   | Clean the build environment only once                   	|           | Boolean  | false    |
| fail_fast    | Stop build if one of packages fails                     	|           | Boolean  | false    |
| full_build   | Download all the package sources except local package   	|           | Boolean  | false    |
| deps_build   | Download packages depends on local package             	 |           | Boolean  | false    |
| threads      | Number of threads to build multiple packages in parallel	|           | Integer  | 0        |
| output_dir   | Output directory       	                                 |           | String   | ""       |
| package_list | Directory list of packages to build                      |           | String   | ""       |


## Example

### Build basics

```yaml  
 steps:
    steps:
    - uses: actions/checkout@v2

    - name: Run build
      uses: retzero/gbs-build-action@master
      with:  
        gbs_conf: ".github/workflows/gbs.conf"
        profile: "tizen"
        architecture: "armv7l"
```

### Storing build outputs

```yaml  
    - name: Run build
      uses: retzero/gbs-build-action@master
      with:  
        gbs_conf: ".github/workflows/gbs.conf"
        profile: "tizen"
        architecture: "armv7l"
        output_dir: ".gbs_build_output"

    - name: Store artifacts
      uses: actions/upload-artifact@v2
      with:
        name: GBS build output
        path: ${{ github.workspace }}/.gbs_build_output/
```

### Multiple packages

```yaml  
    - name: Run build
      uses: retzero/gbs-build-action@master
      with:  
        gbs_conf: ".github/workflows/gbs.conf"
        profile: "tizen"
        architecture: "armv7l"
        package_list: "simple-maps ui-gadget-1"
```
