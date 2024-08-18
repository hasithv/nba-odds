## NBA Odds Calculator

The way this application works is written in this blog post: [https://hasithv.github.io/posts/projects/24-08-17-basketballrandomwalk/](https://hasithv.github.io/posts/projects/24-08-17-basketballrandomwalk/)

### Running the Application
#### Install Julia and Packages
Install Julia on your machine and install the required packages
```Julia
julia> ]add Distributions GenieFramework StippleLatex Genie
```
#### Run the web-app
Navigate into this repo and run
```Julia
julia> using Genie
julia> Genie.loadapp()
julia> up()
```
The site should be running on some localhost.

### Running the Full Model
The full model is contained in `main.jl` and will require the following packages
```Julia
julia> ]add Distributions HCubature CSV DataFrames
```
Now, you should be able to run `main.jl` with no issues.
