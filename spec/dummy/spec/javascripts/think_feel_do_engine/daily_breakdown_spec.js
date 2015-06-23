(function () {
  'use strict';
  var NUM_OF_DAYS = 3;

  describe('when activies exist', function() {
    var activities;

    beforeEach(function() {
      activities = [
        {
          start_datetime: new Date(2015, 5, 15, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 16, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 17, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 18, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 19, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 20, 12).getTime()
        }, {
          start_datetime: new Date(2015, 5, 21, 11).getTime()
        }, {
          start_datetime: new Date(2015, 5, 21, 13).getTime()
        }, {
          start_datetime: new Date(2015, 5, 23, 12).getTime()
        }
      ];
    });

    describe('.filterActivities', function() {
      var baseTime, filteredActivities, timerCallback;

      beforeEach(function() {
        timerCallback = jasmine.createSpy('timerCallback');
        baseTime = new Date(2015, 5, 23, 12);
        jasmine.clock().mockDate(baseTime);
        filteredActivities = sc.filterActivities(activities, NUM_OF_DAYS);
      });

      afterEach(function() {
        jasmine.clock().uninstall();
      });

      it('does not include activities occuring days outside the 3 days ago', function() {
        expect(filteredActivities).not.toContain({
          start_datetime: new Date(2015, 5, 19, 12).getTime()
        });
      });

      it('only includes activities within 3 days', function() {
        expect(filteredActivities.length).toEqual(NUM_OF_DAYS);

        expect(filteredActivities).toContain({
          start_datetime: new Date(2015, 5, 20, 12).getTime()
        });
        expect(filteredActivities).toContain({
          start_datetime: new Date(2015, 5, 21, 11).getTime()
        });
        expect(filteredActivities).toContain({
          start_datetime: new Date(2015, 5, 21, 13).getTime()
        });
      });

      it('does not include activities occuring today', function() {
        expect(filteredActivities).not.toContain({
          start_datetime: new Date(2015, 5, 23, 12).getTime()
        });
      });
    });
  });

  describe('when no activities exist', function() {
    describe('.filterActivities', function() {
      it('returns an empty array', function() {
        expect(sc.filterActivities([], NUM_OF_DAYS)).toEqual([]);
      });
    });

    describe('.splitDateArray', function() {
      it('returns empty array', function() {
        expect(sc.splitDateArray([])).toEqual([]);
      });
    });
  });
}());