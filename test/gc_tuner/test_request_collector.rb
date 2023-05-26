# frozen_string_literal: true

require "test_helper"

module GCTuner
  class TestRequestCollector < Minitest::Test
    def test_request
      heuristic1 = mock
      heuristic2 = mock

      Heuristic.stubs(:enabled_heuristics).returns([
        mock.tap { |m| m.expects(:new).returns(heuristic1) },
        mock.tap { |m| m.expects(:new).returns(heuristic2) },
      ])

      request_collector = RequestCollector.new

      Process.stubs(:clock_gettime).with(Process::CLOCK_MONOTONIC, :float_millisecond)
        .returns(123.0).then.returns(153.0)
      heuristic1.expects(:call).with(30.0, is_a(GCContext), is_a(GCContext))
      heuristic2.expects(:call).with(30.0, is_a(GCContext), is_a(GCContext))
      request_collector.request {}

      Process.stubs(:clock_gettime).with(Process::CLOCK_MONOTONIC, :float_millisecond)
        .returns(400.0).then.returns(500.0)
      heuristic1.expects(:call).with(100.0, is_a(GCContext), is_a(GCContext))
      heuristic2.expects(:call).with(100.0, is_a(GCContext), is_a(GCContext))
      request_collector.request {}
    end
  end
end
