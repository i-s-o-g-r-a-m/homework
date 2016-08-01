#!/usr/bin/env python

import csv
import enum
from collections import defaultdict, namedtuple

from schema import And, Schema, Use
from toolz.itertoolz import concat, first, second, unique


"""
    -- The README says that the SLCSP is 'the second lowest unique
       rate in the rate area.' This was confusing for me, since it
       seems like it would be the second-lowest unique _silver plan_
       rate in the rate area. I decided to assume my interpretation
       was correct, so I'm filtering the plans by silver metal-level
       before determining the second-lowest rate.

    -- I'd usually put exceptions in their own module, but I'm just
       keeping everything in one place for the sake of simplicity.
       Probably would move the schema validation out of here too.

    -- Also probably would add a state lookup list to validate
       against when validating the incoming data.
"""


CONFIG = {
    'output_csv': 'slcsp_rates.csv',
    'plans_csv': 'plans.csv',
    'slcsp_csv': 'slcsp.csv',
    'zips_csv': 'zips.csv',
}


class NoPlansFound(Exception):
    pass


class NoRateAreasFound(Exception):
    pass


class InsufficientRatesFound(Exception):
    pass


class MultipleRateAreasFound(Exception):
    pass


class MetalLevels(enum.Enum):
    Bronze = 'Bronze'
    Silver = 'Silver'
    Gold = 'Gold'
    Platinum = 'Platinum'
    Catastrophic = 'Catastrophic'


RateArea = namedtuple('RateArea', ['number', 'state'])


def read_csv(filename):
    with open(filename) as f:
        reader = csv.DictReader(f)
        rows = [row for row in reader]
    return rows


def validate_plan_data(plans):
    metal_levels = [x[0] for x in MetalLevels.__members__.items()]
    schema = Schema({
        'rate_area': Use(int),
        'plan_id': And(str, len),
        'rate': Use(float),
        'metal_level': lambda x: x in metal_levels,
        'state': And(str, lambda x: len(x) == 2, lambda x: x.isupper())
    })
    for plan in plans:
        schema.validate(plan)
    return plans


def validate_zip_county_data(zip_county_data):
    Schema([Use(int)]).validate(list(zip_county_data.keys()))
    schema = Schema({
        'name': And(str, len),
        'rate_area': Use(int),
        'state': And(str, lambda x: len(x) == 2, lambda x: x.isupper()),
        'zipcode': And(str, lambda x: len(x) == 5 and x.isdigit()),
        'fips': And(str, lambda x: len(x) == 5 and x.isdigit()),
    })
    for county in concat([x for x in zip_county_data.values()]):
        schema.validate(county)
    return zip_county_data


def zip_county_lookup(rows):
    d = defaultdict(list)
    for r in rows:
        d[r['zipcode']].extend([r])
    return d


def filter_plans(rate_area, metal_level, plans):
    return [
        x for x in plans if (
            x['state'] == rate_area.state and
            x['rate_area'] == rate_area.number and
            x['metal_level'] == metal_level
        )
    ]


def find_slcsp(zipcode, counties_lookup, all_plans):
    counties = counties_lookup.get(zipcode, [])
    rate_areas = set([
        (RateArea(state=x['state'], number=x['rate_area']))
        for x in counties
    ])

    if len(rate_areas) > 1:
        raise MultipleRateAreasFound()
    if not rate_areas:
        raise NoRateAreasFound()

    silver_plans = filter_plans(first(rate_areas), MetalLevels.Silver.name, all_plans)
    if not silver_plans:
        raise NoPlansFound()

    silver_plan_rates = list(unique([
        x['rate'] for x in
        sorted(silver_plans, key=lambda y: float(y['rate']))
    ]))

    if len(silver_plan_rates) < 2:
        # how can we determine the second-lowest without at least two?
        # though maybe we are being overly-literal here
        raise InsufficientRatesFound()

    return second(silver_plan_rates)


def main():
    all_plans = validate_plan_data(read_csv(CONFIG['plans_csv']))
    counties_lookup = validate_zip_county_data(
        zip_county_lookup(read_csv(CONFIG['zips_csv']))
    )

    with open(CONFIG['output_csv'], 'w') as output_csv:
        csv_writer = csv.DictWriter(output_csv, fieldnames=['zipcode', 'rate'])
        csv_writer.writeheader()

        suppress_exceptions = (
            InsufficientRatesFound,
            MultipleRateAreasFound,
            NoPlansFound,
            NoRateAreasFound
        )

        for row in read_csv(CONFIG['slcsp_csv']):
            try:
                slcsp = find_slcsp(row['zipcode'], counties_lookup, all_plans)
            except suppress_exceptions:
                slcsp = None
            csv_writer.writerow({
                'zipcode': row['zipcode'],
                'rate': slcsp,
            })


if __name__ == '__main__':
    main()
