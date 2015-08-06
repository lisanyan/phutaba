function highlight() {
  // dummy
  // to be here until the board doesn't hardcode it into posts anymore
}

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
};
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
};
DAG.prototype.flatten = function () {
  // this is not a toposort!
  return this.nodes.map(function (node, i) {
    return i;
  }).filter(function (node, i) {
    return i !== undefined;
  });
};
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
};
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
};
DAG.prototype.ancestors = function (id) {
  return this.reverse().descendants(id);
};

(function () {
var context = {
  // works in threads only. TODO
  show : function (num, highlight) {
    var posts = $j('.content .thread_reply')
      , OPid = +$j('.thread_OP').attr('id')
      , postgraph = createPostGraph(OPid)
      , ancwrap = exists('#ancwrap') ? $j('#ancwrap') : $j('<div id=ancwrap class=context><div id=ancbox>')
      , deswrap = exists('#deswrap') ? $j('#deswrap') : $j('<div id=deswrap class=context><div id=desbox>')
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

    ancbox.find('#c' + highlight).addClass('highlight');
    if (ancestors.length) $j('#'+num).before(ancwrap);
    if (descendants.length) $j('#'+num).after(deswrap);
  },
  hide : function () {
    $j('#ancwrap, #deswrap')
      .detach()
      .find('article')
      .removeClass('highlight');
  }
}, postCache, preview = (function () {
  var previewBox = $j('<div id=preview>')
    , status = []
  ;

  function loadPost(num, callback) {
    $j.get('/' + window.board + '/wakaba.pl?task=show&board=' + window.board + '&post=' + num,
      function (data) {
        var post = $j(data.trim());
        if (!exists(+num)) {
          postCache.append(post);
        }
        callback(post);
      });
  }

  function showPost(p, pos) {
    previewBox.empty()
      .append( p.hasClass('thread_OP') ?
        clonePost(p.attr('id')) :
        p.find('.post').clone() )
      .css({left: pos.X + 5 + 'px', top: pos.Y - p.outerHeight()/2 + 'px'})
      .show()
      .appendTo(document.body);
  }

  return {
    show : function (num, pos, callback) {
      var p = exists('#c' + num) ? $j('#c' + num) :
          exists(+num) ? $j('#' + num) :
          undefined
        , isVisible = p && p.offset().top + p.outerHeight() > window.scrollY &&
          window.scrollY + $j(window).height() > p.offset().top
        , isEntirelyVisible = p && p.offset().top > window.scrollY &&
          window.scrollY + $j(window).height() > p.offset().top + p.outerHeight()
      ;

      if (p) {
        if (!isEntirelyVisible) {
          showPost(p, pos);
        }
        if (isVisible) {
          p.addClass('highlight');
        }
        callback();
      } else {
        if (!status[num]) {
          loadPost(num, function (post) {
            if (status[num] !== "aborted") {
              showPost(post, pos, previewBox);
              callback();
              status[num] = "loaded";
            }
          });
        }
        status[num] = "loading";
      }
    },
    hide : function (num) {
      var posts = $j('#' + num + ',#c' + num);
      status[num] = "aborted";
      previewBox.hide().empty();
      posts.removeClass('highlight');
    }
  };
})();


function createPostGraph(OP) {
  var graph = new DAG(OP);
  graph.addPost = function () {
    var post = $j(this)
      , refs = post.find('span.backreflink a')
      , num = +post.attr('id')
    ;
    graph.append(refs.map(function () {
      return +getTarget(this);
    }).toArray().filter(function (x) {
      return exists('.content #' + x);
    }), num);
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
  return (a.attr ? a.attr('href') : a.getAttribute('href')).match(/\d+/g).pop();
}

function exists (query) {
  return !!(typeof query === 'number' ? document.getElementById(query) : $j(query).length);
}


$j(document).ready(function() {
  postCache = $j('<div id=post_cache>').appendTo($j('body'));
  $j('body').on('mouseenter', 'span.backreflink a', function (ev) {
    var el = $j(ev.target)
      , pos = el.offset()
    ;
    el.css({cursor: 'progress'});
    preview.show(getTarget(ev.target),
      {X: pos.left + el.outerWidth(), Y: pos.top + el.outerHeight()/2},
      function () { el.css({cursor: ''}); });
  });
  $j('body').on('mouseleave', 'span.backreflink a', function (ev) {
    var el = $j(ev.target);
    el.css({cursor: ''});
    preview.hide(getTarget(el));
  });
  $j('body').on('click', 'span.backreflink a', function (ev) {
    var el = $j(ev.target)
      , id = +getTarget(el)
    ;

    if ($j('.content #' + id).length && window.thread_id) {
      ev.preventDefault();
      if (!el.is('.context *')) {
        preview.hide(getTarget(el));
        context.hide();
        context.show(+el.closest('.thread_reply').attr('id'), id);
      }
    }
  });
  $j('body').on('click', function (ev) {
    var el = $j(ev.target);
    if (!el.is('.context, .context *, span.backreflink a')) {
      context.hide();
    }
  });
});
})();
