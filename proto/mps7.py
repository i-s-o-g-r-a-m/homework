#!/usr/bin/env python

import argparse
import collections
import datetime
import enum
import locale
import sys


class UnrecognizedFormat(Exception):
    pass


class UnsupportedVersion(Exception):
    pass


class RecordTypes(enum.Enum):
    Debit = 0
    Credit = 1
    StartAutopay = 2
    EndAutopay = 3


Record = collections.namedtuple('Record', [
    'record_type',
    'timestamp',
    'user_id',
    'dollar_amount',
])


class Reader:
    """
    Reads MPS7 (v1) payment-processing record data and provides
    an iterator for consuming the data
    """

    BYTE_ORDER = 'big'
    MAGIC_STRING = 'MPS7'
    SUPPORTED_VERSION = 1

    def __init__(self, path):
        self.file = open(path, 'rb')
        self._index = None
        self._record_count = None
        self._setup()

    def _setup(self):
        self.file.seek(0)
        self._read_header()
        self._index = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self._index < self._record_count:
            self._index += 1
            return self.next_record()
        raise StopIteration

    def _read_header(self):
        if self.file.read(4).decode('us-ascii') != self.MAGIC_STRING:
            raise UnrecognizedFormat(
                'The input data is malformed or has the wrong format.'
            )

        format_version = self._int_from_bytes(1)
        if format_version != self.SUPPORTED_VERSION:
            raise UnsupportedVersion(
                'Input data reports an unsupported version; '
                'expected version {}, got version {}'
                .format(self.SUPPORTED_VERSION, format_version)
            )

        self._record_count = self._int_from_bytes(4)

    def _int_from_bytes(self, num_bytes):
        return int.from_bytes(
            self.file.read(num_bytes),
            byteorder=self.BYTE_ORDER
        )

    def reset(self):
        self._setup()

    def close(self):
        self.file.close()

    def next_record(self):
        record_type = RecordTypes(self._int_from_bytes(1))
        timestamp = datetime.datetime.fromtimestamp(self._int_from_bytes(4))
        user_id = self._int_from_bytes(8)

        if record_type in (RecordTypes.Debit, RecordTypes.Credit):
            dollar_amount = self._int_from_bytes(8)
        else:
            dollar_amount = None

        return Record(
            record_type=record_type,
            timestamp=timestamp,
            user_id=user_id,
            dollar_amount=dollar_amount
        )


def aggregates(reader):
    """
    Computes some aggregate values across the full set of records
    """

    locale.setlocale(locale.LC_ALL, '')

    autopay_start_count = 0
    autopay_end_count = 0
    total_credits = 0
    total_debits = 0

    for record in reader:
        if record.record_type == RecordTypes.Debit:
            total_debits += record.dollar_amount
        if record.record_type == RecordTypes.Credit:
            total_credits += record.dollar_amount
        if record.record_type == RecordTypes.StartAutopay:
            autopay_start_count += 1
        if record.record_type == RecordTypes.EndAutopay:
            autopay_end_count += 1

    print('total debits:', locale.currency(total_debits, grouping=True))
    print('total credits:', locale.currency(total_credits, grouping=True))
    print('autopays started:', autopay_start_count)
    print('autopays ended:', autopay_end_count)


def get_balance(reader, user_id):
    """
    Returns the current balance for the user
    """

    balance = 0

    for record in reader:
        if record.user_id != user_id:
            continue
        if record.record_type == RecordTypes.Debit:
            balance -= record.dollar_amount
        if record.record_type == RecordTypes.Credit:
            balance += record.dollar_amount

    return balance


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'filename',
        metavar='filename',
        type=str,
        nargs=1,
        help='path to the transaction log file to be processed'
    )
    return parser.parse_args()


def main():
    reader = Reader(parse_args().filename[0])

    aggregates(reader)
    reader.reset()

    user_id = 2456938384156277127
    print('balance for {}:'.format(user_id), get_balance(reader, user_id=user_id))

    reader.close()


if __name__ == '__main__':
    main()
