const std = @import("std");

pub fn sleep_ms(ms: u64) void {
    std.time.sleep(std.time.millisecond * ms);
}
