// Generated by CoffeeScript 1.7.1
(function() {
  var Directive, DirectoryManager, NeedDirective, PHPRouteBuilder, ParentDirective, ParentDirectiveTest, PlaceholderTest, RenderDirective, RenderDirectiveTest, RepeatDirective, RepeatDirectiveTest, RouteTest, SectionDirective, SectionDirectiveTest, TestCase, TestDirective, TestDirectoryManager, TestNeedDirectiveTest, Variable, async,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  TestCase = require("beast-test").TestCase;

  PHPRouteBuilder = require("../bin/index.js").PHPRouteBuilder;

  new (RouteTest = (function(_super) {
    __extends(RouteTest, _super);

    function RouteTest() {
      RouteTest.__super__.constructor.call(this);
    }

    RouteTest.prototype.base = function() {
      return new PHPRouteBuilder("demo/routebuilder/routes.json");
    };

    RouteTest.prototype.testRouteBuilder = function(builder) {
      return builder["export"]("demo/application/routes.json");
    };

    return RouteTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  Variable = require("../bin/index.js").Variable;

  new (PlaceholderTest = (function(_super) {
    __extends(PlaceholderTest, _super);

    function PlaceholderTest() {
      PlaceholderTest.__super__.constructor.call(this);
    }

    PlaceholderTest.prototype.base = function() {
      return new Variable();
    };

    PlaceholderTest.prototype.testVariable = function(v) {
      var text;
      text = "{{hello blah blah}}";
      this.assertTrue(v.canHandle(text));
      this.assertEquals(v.getReplacement(text), "<?php echo $hello ?>");
      return this.assertEquals(v.getPreviewReplacement(text), "blah blah");
    };

    return PlaceholderTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  DirectoryManager = require("../bin/index.js").DirectoryManager;

  async = require("async");

  new (TestDirectoryManager = (function(_super) {
    __extends(TestDirectoryManager, _super);

    function TestDirectoryManager() {
      TestDirectoryManager.__super__.constructor.call(this);
    }

    TestDirectoryManager.prototype.base = function() {
      return new DirectoryManager();
    };

    TestDirectoryManager.prototype.testReadingFiles = function(dm) {
      return async.series([
        function(callback) {
          var allFileLoadedandParsed;
          process.output.debug("starting to load directory");
          allFileLoadedandParsed = function(err) {
            process.output.debug("allfiledloadedandparse has been called");
            callback.call();
            return process.output.debug("all files loaded and parsed");
          };
          return dm.loadFiles("demo/viewbuilder", "demo/preview", "html$", "^(node_modules|\\.)", allFileLoadedandParsed);
        }, (function(_this) {
          return function(callback) {
            _this.assertTrue(dm.files.length > 0);
            callback.call();
            return process.output.debug(dm);
          };
        })(this)
      ], (function(_this) {
        return function() {
          console.log("needed to be printed here because of async task that finished later");
          return console.log(TestCase.getResult());
        };
      })(this));
    };

    TestDirectoryManager.prototype.testViewBuilder = function(dm) {
      return async.series([
        function(callback) {
          return dm.buildView("demo/viewbuilder", "demo/application/app/view", "html$", null, callback);
        }
      ]);
    };

    return TestDirectoryManager;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  SectionDirective = require("../bin/index.js").SectionDirective;

  new (SectionDirectiveTest = (function(_super) {
    __extends(SectionDirectiveTest, _super);

    function SectionDirectiveTest() {
      SectionDirectiveTest.__super__.constructor.call(this);
    }

    SectionDirectiveTest.prototype.base = function() {
      var d;
      return d = new SectionDirective("fake", "fake");
    };

    SectionDirectiveTest.prototype.testAbstractClass = function(obj) {
      this.assertNotNull(obj);
      return this.assertTrue(obj.canHandle("#section parent section"));
    };

    return SectionDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  RepeatDirective = require("../bin/index.js").RepeatDirective;

  new (RepeatDirectiveTest = (function(_super) {
    __extends(RepeatDirectiveTest, _super);

    function RepeatDirectiveTest() {
      RepeatDirectiveTest.__super__.constructor.call(this);
    }

    RepeatDirectiveTest.prototype.base = function() {
      var d;
      return d = new RepeatDirective;
    };

    RepeatDirectiveTest.prototype.testAbstractClass = function(obj) {
      this.assertNotNull(obj);
      this.assertTrue(obj.canHandle("#repeat 4"));
      return this.assertTrue(!obj.canHandle("#repe 4"));
    };

    return RepeatDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  ParentDirective = require("../bin/index.js").ParentDirective;

  new (ParentDirectiveTest = (function(_super) {
    __extends(ParentDirectiveTest, _super);

    function ParentDirectiveTest() {
      ParentDirectiveTest.__super__.constructor.call(this);
    }

    ParentDirectiveTest.prototype.base = function() {
      var d;
      return d = new ParentDirective("fake", "fake");
    };

    ParentDirectiveTest.prototype.testAbstractClass = function(obj) {
      this.assertNotNull(obj);
      return this.assertTrue(obj.canHandle("#parent content"));
    };

    return ParentDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  RenderDirective = require("../bin/index.js").RenderDirective;

  new (RenderDirectiveTest = (function(_super) {
    __extends(RenderDirectiveTest, _super);

    function RenderDirectiveTest() {
      RenderDirectiveTest.__super__.constructor.call(this);
    }

    RenderDirectiveTest.prototype.base = function() {
      var d;
      return d = new RenderDirective;
    };

    RenderDirectiveTest.prototype.testRenderDirective = function(obj) {
      this.assertNotNull(obj);
      return this.assertTrue(obj.canHandle("#render"));
    };

    return RenderDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  NeedDirective = require("../bin/index.js").NeedDirective;

  new (TestNeedDirectiveTest = (function(_super) {
    __extends(TestNeedDirectiveTest, _super);

    function TestNeedDirectiveTest() {
      TestNeedDirectiveTest.__super__.constructor.call(this);
    }

    TestNeedDirectiveTest.prototype.base = function() {
      var d;
      return d = new NeedDirective("fake", "fake");
    };

    TestNeedDirectiveTest.prototype.testAbstractClass = function(obj) {
      this.assertNotNull(obj);
      return this.assertTrue(obj.canHandle("#need content"));
    };

    return TestNeedDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  Directive = require("../bin/index.js").Directive;

  new (TestDirective = (function(_super) {
    __extends(TestDirective, _super);

    function TestDirective() {
      TestDirective.__super__.constructor.call(this);
    }

    TestDirective.prototype.base = function() {
      var d, e;
      try {
        d = new Directive("fake", "fake");
      } catch (_error) {
        e = _error;
        return e;
      }
      return d;
    };

    TestDirective.prototype.testAbstractClass = function(obj) {
      return this.assertEquals(obj.message, "Class Directive is an Abstract Class");
    };

    return TestDirective;

  })(TestCase));

  console.log(TestCase.getResult());

}).call(this);
