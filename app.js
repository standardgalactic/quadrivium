d3.json("structure.json").then(data => {
	    const width = window.innerWidth;
	    const height = window.innerHeight;

	    const root = d3.hierarchy(data[0], d => d.contents)
	        .sum(d => d.type === "file" ? 1 : 0)
	        .sort((a, b) => b.value - a.value);

	    const pack = d3.pack()
	        .size([width, height])
	        .padding(3);

	    pack(root);

	    const svg = d3.select("svg");
	    const nodes = svg.selectAll("circle")
	        .data(root.descendants())
	        .enter().append("circle")
	        .attr("cx", d => d.x)
	        .attr("cy", d => d.y)
	        .attr("r", d => d.r)
	        .attr("fill", d => d.children ? "#69b3a2" : "#ffcc00");
});

