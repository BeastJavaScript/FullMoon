// Generated by CoffeeScript 1.7.1
(function() {
  var Directive, NeedDirective, ParentDirective, ParentDirectiveTest, RepeatDirective, RepeatDirectiveTest, SectionDirective, SectionDirectiveTest, TestCase, TestDirective, TestNeedDirectiveTest,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  TestCase = require("beast-test").TestCase;

  SectionDirective = require("../lib/Application.js").SectionDirective;

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
      return this.assertNotNull(obj);
    };

    return SectionDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  RepeatDirective = require("../lib/Application.js").RepeatDirective;

  new (RepeatDirectiveTest = (function(_super) {
    __extends(RepeatDirectiveTest, _super);

    function RepeatDirectiveTest() {
      RepeatDirectiveTest.__super__.constructor.call(this);
    }

    RepeatDirectiveTest.prototype.base = function() {
      var d;
      return d = new RepeatDirective("fake", "fake");
    };

    RepeatDirectiveTest.prototype.testAbstractClass = function(obj) {
      return this.assertNotNull(obj);
    };

    return RepeatDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  ParentDirective = require("../lib/Application.js").ParentDirective;

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
      return this.assertNotNull(obj);
    };

    return ParentDirectiveTest;

  })(TestCase));

  TestCase = require("beast-test").TestCase;

  NeedDirective = require("../lib/Application.js").NeedDirective;

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

  Directive = require("../lib/Application.js").Directive;

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
