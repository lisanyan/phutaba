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


// works in threads only. TODO
var context = {
  show : function showContext (num, highlight) {
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
    ancestors = exclude(postgraph.ancestors(num).flatten(), [num]);
    
    ancestors.forEach(function (i) {
        ancbox.append(clonePost(i));
    });
    descendants.forEach(function (i) {
        desbox.append(clonePost(i));
    });

    if (ancestors.length) $j('#'+num).before(ancwrap);
    if (descendants.length) $j('#'+num).after(deswrap);
  },
  hide : function hideContext() {
    $j('#ancwrap, #deswrap').detach();
  }
}, preview = {
  show : function showPreview(num, pos) {
    var p = $j('#ancbox').length ? $j('#c' + num) : $j('#' + num)
      , isVisible = p.position().top + p.outerHeight() > window.scrollY &&
        window.scrollY + $j(window).height() > p.position().top
      , isEntirelyVisible = p.position().top > window.scrollY &&
        window.scrollY + $j(window).height() > p.position().top + p.outerHeight()
    ;
    console.log(pos);
    if (isVisible)
      p.addClass('highlight');
    if (!isEntirelyVisible) {
      ($j('#preview').length ?
        $j('#preview') :
        $j('<div id=preview>').append(clonePost(p.attr('id'))))
        .css({left: pos.X + 'px', top: pos.Y + 'px'})
        .appendTo(document.body);
    }

  },
  hide : function hidePreview(num) {
    var posts = $j('#' + num + ',#c' + num);
    $j('#preview').detach();
    posts.removeClass('highlight');
  }
};


function createPostGraph(OP) {
  var graph = new DAG(OP);
  graph.addPost = function () {
    var post = $j(this)
      , refs = post.find('span.backreflink a')
      , num = +post.attr('id')
    ;
    graph.append(refs.map(function () {
          return +getTarget(this);
       }).toArray(),
     num);
  }
  return graph;
}

function exclude (arr, without) {
  return arr.filter(function (x) {
    return !(without.indexOf(x) >= 0);
  })
}

function clonePost (id) {
  var post = $j('#' + id).clone();
  post.attr('id', 'c' + id);
  post.find('span.backreflink a').attr('href', function (i, href) {
    return href.replace('#', '#c');
  });
  return post
}

function getTarget (a) {
  return (a.attr ? a.attr('href') : a.getAttribute('href')).match(/c?\d+/g).pop();
}

function highlight() {
  // dummy
  // to be here until the board doesn't hardcode it into posts anymore
}


$j(document).ready(function() {
  $j('body').on('mouseenter', 'span.backreflink a', function (ev) {
    preview.show(getTarget(ev.target), {X: ev.pageX, Y: ev.pageY});
  });
  $j('body').on('mouseleave', 'span.backreflink a', function (ev) {
    preview.hide(getTarget(ev.target));
  });
  $j('body').on('click', 'span.backreflink a', function (ev) {
    var el = $j(ev.target);
    ev.preventDefault();
    if (!el.is('.context *')) {
      context.hide();
      context.show(+el.closest('.thread_reply').attr('id'), +getTarget(el));
    }
  });
  $j('body').on('click', function (ev) {
    var el = $j(ev.target);
    if (!el.is('.context, .context *, span.backreflink a')) {
      context.hide();
    }
  });
});

