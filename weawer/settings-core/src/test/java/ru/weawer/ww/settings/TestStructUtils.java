package ru.weawer.ww.settings;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;

import ru.weawer.ww.sett.ComplexTypes;
import ru.weawer.ww.sett.En1;
import ru.weawer.ww.sett.MyStr1;
import ru.weawer.ww.sett.MyStr2;
import ru.weawer.ww.sett.SimpleTypes;

public class TestStructUtils {

	private static final UUID uuid = UUID.randomUUID();
	private static final LocalDate d = LocalDate.now();
	private static final LocalTime t = LocalTime.now();
	private static final LocalDateTime dt = LocalDateTime.now();
	private static final long ts = System.currentTimeMillis();
	
	public static SimpleTypes getSimpleTypes() {
		
		
		return SimpleTypes.builder()
				.en(En1.ONE)
				.b(true)
				.bt((byte) 0x02)
				.c('f')
				.s((short) -12)
				.i(Integer.MAX_VALUE)
				.l(-200000)
				.f(23.23f)
				.dds(1.1e-18)
				.str("Hello, world!")
				.d(d)
				.t(t)
				.dt(dt)
				.ts(ts)
				.g(uuid)
				.ba(new byte[] { 0x12, 0x13 })
				.build();
	}
	
	public static MyStr1 getMyStr1() {
		Map<LocalDate, Boolean> m1 = ImmutableMap.of(LocalDate.parse("2016-08-29"), false, LocalDate.parse("2016-08-30"), true);
		Map<LocalDate, Boolean> m2 = ImmutableMap.of(LocalDate.parse("2016-08-31"), true);
		Map<LocalDate, Boolean> m3 = ImmutableMap.of();
		List<Map<LocalDate, Boolean>> l = new ArrayList<Map<LocalDate, Boolean>>();
		l.add(m1);
		l.add(m2);
		l.add(m3);
		
		return MyStr1.builder().lo(-1l).li(l).build();
	}
	
	public static MyStr2 getMyStr2() {
		return MyStr2.builder().s("id").s1(getMyStr1()).build();
	}
	
	public static ComplexTypes getComplexTypes() {
		List<String> listString = Lists.newArrayList("sta", "asdefih234");
		ComplexTypes t = ComplexTypes.builder()
			.listString(listString)
			.listIntString(ImmutableMap.of(1, "a", 2, "b"))
			.m(ImmutableMap.of()) //1.1, Lists.newArrayList(En1.ONE, En1.ONE), 8d, Lists.newArrayList(En1.TWO))) 
			.s1(getMyStr1())
			.s2(getMyStr2())
			.build();
		return t;
		
	}
}
