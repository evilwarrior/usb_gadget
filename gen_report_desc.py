#!/usr/bin/env python3

kb_report_desc = bytes((
    0x05, 0x01, # USAGE_PAGE (Generic Desktop)
    0x09, 0x06, # USAGE (Keyboard)
    0xa1, 0x01, # COLLECTION (Application)

    # 8 bits modifiers
    0x05, 0x07, # - USAGE_PAGE (Keyboard)
    0x19, 0xe0, # - USAGE_MINIMUM (Keyboard LeftControl)
    0x29, 0xe7, # - USAGE_MAXIMUM (Keyboard Right GUI)
    0x15, 0x00, # - LOGICAL_MINIMUM (0)
    0x25, 0x01, # - LOGICAL_MAXIMUM (1)
    0x75, 0x01, # - REPORT_SIZE (1)
    0x95, 0x08, # - REPORT_COUNT (8)
    0x81, 0x02, # - INPUT (Data,Var,Abs)

    # 1 byte reserved
    0x95, 0x01, # - REPORT_COUNT (1)
    0x75, 0x08, # - REPORT_SIZE (8)
    0x81, 0x03, # - INPUT (Const,Var,Abs)

    # 5 bits LEDs output
    0x95, 0x05, # - REPORT_COUNT (5)
    0x75, 0x01, # - REPORT_SIZE (1)
    0x05, 0x08, # - USAGE_PAGE (LEDs)
    0x19, 0x01, # - USAGE_MINIMUM (Num Lock)
    0x29, 0x05, # - USAGE_MAXIMUM (Kana)
    0x91, 0x02, # - OUTPUT (Data,Var,Abs)

    # 3 bits reserved output
    0x95, 0x01, # - REPORT_COUNT (1)
    0x75, 0x03, # - REPORT_SIZE (3)
    0x91, 0x03, # - OUTPUT (Const,Var,Abs)

    # 6 bytes keys
    0x95, 0x06, # - REPORT_COUNT (6)
    0x75, 0x08, # - REPORT_SIZE (8)
    0x15, 0x00, # - LOGICAL_MINIMUM (0)
    0x25, 0x65, # - LOGICAL_MAXIMUM (101)
    0x05, 0x07, # - USAGE_PAGE (Keyboard)
    0x19, 0x00, # - USAGE_MINIMUM (Reserved)
    0x29, 0x65, # - USAGE_MAXIMUM (Keyboard Application)
    0x81, 0x00, # - INPUT (Data,Array,Abs)
    0xc0        # END_COLLECTION
))

m_report_desc = bytes((
    0x05, 0x01, # USAGE_PAGE (Generic Desktop)
    0x09, 0x02, # USAGE (Mouse)
    0xa1, 0x01, # COLLECTION (Application)

    0x09, 0x01, # - USAGE (Pointer)
    0xa1, 0x00, # - COLLECTION (Physical)

    # 3 bits buttons
    0x05, 0x09, #  - USAGE_PAGE (Button)
    0x19, 0x01, #  - USAGE_MINIMUM (Logical Left)
    0x29, 0x03, #  - USAGE_MAXIMUM (Logical Middle)
    0x15, 0x00, #  - LOGICAL_MINIMUM (0)
    0x25, 0x01, #  - LOGICAL_MAXIMUM (1)
    0x95, 0x03, #  - REPORT_COUNT (3)
    0x75, 0x01, #  - REPORT_SIZE (1)
    0x81, 0x02, #  - INPUT (Data,Var,Abs)

    # 5 bits reserved
    0x95, 0x01, #  - REPORT_COUNT (1)
    0x75, 0x05, #  - REPORT_SIZE (5)
    0x81, 0x03, #  - INPUT (Const,Var,Abs)

    # 1 byte for each x, y, wheel
    0x05, 0x01, #  - USAGE_PAGE (Generic Desktop)
    0x09, 0x30, #  - USAGE (X)
    0x09, 0x31, #  - USAGE (Y)
    0x09, 0x38, #  - USAGE (Wheel)
    0x15, 0x81, #  - LOGICAL_MINIMUM (-127)
    0x25, 0x7f, #  - LOGICAL_MAXIMUM (127)
    0x75, 0x08, #  - REPORT_SIZE (8)
    0x95, 0x03, #  - REPORT_COUNT (3)
    0x81, 0x06, #  - INPUT (Data,Var,Rel)
    0xc0,       # - END_COLLECTION
    0xc0        # END_COLLECTION
))

if __name__ == '__main__':
    import sys, os
    if len(sys.argv) < 3:
        sys.stderr.write('Require keyboard and mouse descriptor binaries path arguments!\n')
        sys.exit(1)

    # keyboard descriptor
    kb_path = sys.argv[1]
    if not os.path.exists(os.path.dirname(kb_path)) or os.path.isdir(kb_path):
        sys.stderr.write(f'Cannot create keyboard descriptor binary {kb_path}!\n')
        sys.exit(1)

    # keyboard descriptor
    m_path = sys.argv[2]
    if not os.path.exists(os.path.dirname(m_path)) or os.path.isdir(m_path):
        sys.stderr.write(f'Cannot create mouse descriptor binary {m_path}!\n')
        sys.exit(1)

    with open(kb_path, 'wb') as f:
        f.write(kb_report_desc)

    with open(m_path, 'wb') as f:
        f.write(m_report_desc)
