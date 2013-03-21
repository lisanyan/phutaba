function DAG(id) {
  this.nodes = [];
  if (id !== undefined) {
    this.head = id;
    this.nodes[id] = {
      parents: [],
      children: []
    };
  }
}
DAG.prototype.append = function (parents, id) {
  var nodes = this.nodes;
  if (nodes[id]) {
    return false;
  } else {
    nodes[id] = {
      parents : parents,
      children : []
    };
    parents.forEach(function (p) {
      nodes[p].children.push(id);
    });
    return true;
  }
}
DAG.prototype.attach = function (parents, sub) {
  var nodes = this.nodes;
  if (sub.nodes.filter(function (el) {
    return nodes[el.id] !== undefined;
  }).length) {
    return false;
  } else {
    sub.nodes.forEach(function (node, i) {
      nodes[i] = node;
    });
    nodes[sub.head].parents = parents;
    parents.forEach(function (p) {
      nodes[p].children.push(sub.head);
    });
    return true;
  }
}
DAG.prototype.flatten = function () {
  // this is not a toposort!
  return this.nodes.map(function (node, i) {
    return i;
  }).filter(function (node, i) {
    return i !== undefined;
  });
}
DAG.prototype.reverse = function () {
  var out = new DAG();
  this.nodes.forEach(function (node, i) {
    if (out.head === undefined && !node.children.length) {
      out.head = i;
    }
    out.nodes[i] = {
      parents: node.children,
      children: node.parents
    };
  });
  return out;
}
DAG.prototype.descendants = function (id) {
  var out = new DAG(id),
    self = this;
  self.nodes[id].children.forEach(function (child) {
    if (out.nodes[child]) {
      out.nodes[child].parents.push(id);
    } else {
      out.attach([id], self.descendants(child));
    }
  });
  return out;
}
DAG.prototype.ancestors = function (id) {
  return this.reverse().descendants(id);
}


$j(['<style type="text/css">',
//  , '#context { position: fixed; top: 2em; right: 2em; bottom: 2em; left: 10em; overflow-y: auto; }'
//  , '#context td { display: block; float: none; }'
//  , '.popup { background: #aaaacc; border: 2px solid #444488; padding: 3px; }'
  , '#ancbox { bottom: 0.25em; }'
  , '#desbox { top: -0.25em; }'
  , '.context { position: relative; clear: left }'
  , '.context > div { border: 1px solid rgb(99, 85, 55); background-color: rgb(236, 233, 226); position: absolute; left: 10em; }'
  , '.context .thread_reply { margin-right: 0.5em; }'
  , '.context .thread_reply:first-of-type { margin-top: 0.5em; }'
  , '.thread_head { clear: left; }' // TODO integrate into main stylesheet
  , '</style>' // TODO .doubledash
].join('\n')).appendTo('head');

function createPostGraph(OP) {
  var graph = new DAG(OP);
  graph.addPost = function () {
    var post = $j(this)
      , refs = post.find('span.backreflink a')
      , num = +post.attr('id')
    ;
    graph.append(
       refs.length ? refs.map(function () {
          return +this.getAttribute('href').match(/\d+/g).pop();
       }).toArray() : [OP],
     num);
  }
  return graph;
}

function exclude (arr, without) {
  return arr.filter(function (x) {
    return !(without.indexOf(x) >= 0);
  })
}

// works in threads only. TODO
function showContext (num, highlight) {
  var posts = $j('.thread_reply')
    , OPid = +$j('.thread_OP').attr('id')
    , postgraph = createPostGraph(OPid)
    , ancwrap = $j('#ancwrap').length ? $j('#ancwrap') : $j('<div id=ancwrap class=context><div id=ancbox>')
    , deswrap = $j('#deswrap').length ? $j('#deswrap') : $j('<div id=deswrap class=context><div id=desbox>')
    , ancbox = ancwrap.find(':first-child').empty()
    , desbox = deswrap.find(':first-child').empty()
    , dummy = $j('<div id=dummy class=dummy>')
    , ancestors
    , descendants
  ;
  // generate the graph every time - we can optimize this later
  posts.each(postgraph.addPost);
  
  descendants = exclude(postgraph.descendants(num).flatten(), [num]);
  ancestors = exclude(postgraph.ancestors(num).flatten(), [num, highlight]).concat(highlight);
  
  ancestors.forEach(function (i) {
      ancbox.append($j('#' + i).clone().removeAttr('id'));
  });
  descendants.forEach(function (i) {
      desbox.append($j('#' + i).clone().removeAttr('id'));
  });

  if (ancestors.length) $j('#'+num).before(ancwrap);
  if (descendants.length) $j('#'+num).after(deswrap);
}

function getPost (num) {
  var post = $('post-' + num);
  return post ? post.up('table') : document.createElement('table');
}

function hideContext() {
  $j('#ancwrap, #deswrap').detach();
}

window.highlight = function (){};

$j(document).ready(function() {
  $j('body').on('click', 'span.backreflink a', function (ev) {
    var el = $j(ev.target);
    ev.preventDefault();
    if (!el.is('.context *')) {
      hideContext();
      showContext(+el.closest('.thread_reply').attr('id'),
        +el.attr('href').match(/\d+/g).pop());
    }
  });
  $j('body').on('click', function (ev) {
    var el = $j(ev.target);
    if (!el.is('.context, .context *, span.backreflink a')) {
      hideContext();
    }
  });
});

