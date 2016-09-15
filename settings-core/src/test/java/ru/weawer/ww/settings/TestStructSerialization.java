package ru.weawer.ww.settings;

import static org.junit.Assert.assertEquals;

import java.nio.ByteBuffer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;

import ru.weawer.ww.JSONStructSerializer;
import ru.weawer.ww.sett.ChildStruct;
import ru.weawer.ww.sett.ComplexTypes;
import ru.weawer.ww.sett.En1;
import ru.weawer.ww.sett.MyStr1;
import ru.weawer.ww.sett.MyStr2;
import ru.weawer.ww.sett.SimpleTypes;

public class TestStructSerialization {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testSimleTypesJson() {
		SimpleTypes t0 = getSimpleTypes();		
		SimpleTypes t1 = (SimpleTypes) JSONStructSerializer.fromJson(t0.toJson());
		
		assertEquals(t0.en(), t1.en());
		assertEquals(t0.b(), t1.b());
		assertEquals(t0.bt(), t1.bt());
		assertEquals(t0.c(), t1.c());
		assertEquals(t0.s(), t1.s());
		assertEquals(t0.i(), t1.i());
		assertEquals(t0.l(), t1.l());
		assertEquals(t0.f(), t1.f(), 0);
		assertEquals(t0.dds(), t1.dds(), 0);
		assertEquals(t0.str(), t1.str());
		assertEquals(t0.d(), t1.d());
		assertEquals(t0.t(), t1.t());
		assertEquals(t0.dt(), t1.dt());
		assertEquals(t0.ts(), t1.ts());
		assertEquals(t0.g(), t1.g());
		assertEquals(t0.ba().length, t1.ba().length);
		for(int i = 0; i < t0.ba().length; i++) assertEquals(t0.ba()[i], t1.ba()[i]);
		
		assertEquals(t0.toJson(), t1.toJson());
		
		
		
	}
	
	@Test
	public void testSimleTypesBinary() {
		
		
		SimpleTypes t0 = getSimpleTypes();
		
		SimpleTypes t1 = SimpleTypes.fromByteBuf(ByteBuffer.wrap(t0.toByteArray()));
		
		assertEquals(t0.en(), t1.en());
		assertEquals(t0.b(), t1.b());
		assertEquals(t0.bt(), t1.bt());
		assertEquals(t0.c(), t1.c());
		assertEquals(t0.s(), t1.s());
		assertEquals(t0.i(), t1.i());
		assertEquals(t0.l(), t1.l());
		assertEquals(t0.f(), t1.f(), 0);
		assertEquals(t0.dds(), t1.dds(), 0);
		assertEquals(t0.str(), t1.str());
		assertEquals(t0.d(), t1.d());
		assertEquals(t0.t(), t1.t());
		assertEquals(t0.dt(), t1.dt());
		assertEquals(t0.ts(), t1.ts());
		assertEquals(t0.g(), t1.g());
		assertEquals(t0.ba().length, t1.ba().length);
		for(int i = 0; i < t0.ba().length; i++) assertEquals(t0.ba()[i], t1.ba()[i]);
		
		assertEquals(t0.toJson(), t1.toJson());
		
		
		
	}
	
	@Test
	public void testMyStr1Json() {
		MyStr1 s0 = getMyStr1();
		MyStr1 s1 = (MyStr1) JSONStructSerializer.fromJson(s0.toJson());
		
		assertEquals(s0.lo(), s1.lo());
		assertEquals(s0.li(), s1.li());
		assertEquals(s0, s1);
	}
	
	@Test
	public void testMyStr1Binary() {
		MyStr1 s0 = getMyStr1();		
		MyStr1 s1 = MyStr1.fromByteBuf(ByteBuffer.wrap(s0.toByteArray()));
		
		assertEquals(s0.lo(), s1.lo());
		assertEquals(s0.li(), s1.li());
		assertEquals(s0, s1);
	}
	
	@Test
	public void testMyStr2Json() {
		MyStr2 s0 = getMyStr2();
		MyStr2 s1 = (MyStr2) JSONStructSerializer.fromJson(s0.toJson());
		
		assertEquals(s0.s(), s1.s());
		assertEquals(s0.s1(), s1.s1());
		assertEquals(s0, s1);
	}
	
	@Test
	public void testMyStr2Binary() {
		MyStr2 s0 = getMyStr2();		
		MyStr2 s1 = MyStr2.fromByteBuf(ByteBuffer.wrap(s0.toByteArray()));
		
		assertEquals(s0.s(), s1.s());
		assertEquals(s0.s1(), s1.s1());
		assertEquals(s0, s1);
	}
	
	@Test
	public void testComplexTypesJson() {
		ComplexTypes t0 = getComplexTypes();
		ComplexTypes t1 = (ComplexTypes) JSONStructSerializer.fromJson(t0.toJson());
		assertEquals(t0, t1);
	}
	
	@Test
	public void testComplexTypesBinary() {
		ComplexTypes t0 = getComplexTypes();
		ComplexTypes t1 = ComplexTypes.fromByteBuf(ByteBuffer.wrap(t0.toByteArray()));
		
		assertEquals(t0, t1);
	}
	
	@Test
	public void testInterfaceBinary1() {
		ChildStruct c0 = ChildStruct.builder().b("test12").base(getMyStr1()).l(-34l).s1("s1").s2(12431234213123423l).build();
		ChildStruct c1 = ChildStruct.fromByteBuf(ByteBuffer.wrap(c0.toByteArray()));
		assertEquals(c0, c1);
	}
	
	@Test
	public void testInterfaceBinary2() {
		ChildStruct c0 = ChildStruct.builder().b("test12").base(getMyStr2()).l(-34l).s1("s1").s2(12431234213123423l).build();
		ChildStruct c1 = ChildStruct.fromByteBuf(ByteBuffer.wrap(c0.toByteArray()));
		assertEquals(c0, c1);
	}
	
	@Test
	public void testInterfaceJson1() {
		ChildStruct c0 = ChildStruct.builder().b("test12").base(getMyStr1()).l(-34l).s1("s1").s2(12431234213123423l).build();
		ChildStruct c1 = (ChildStruct) JSONStructSerializer.fromJson(c0.toJson());
		assertEquals(c0, c1);
	}
	
	@Test
	public void testInterfaceJson2() {
		ChildStruct c0 = ChildStruct.builder().b("test12").base(getMyStr2()).l(-34l).s1("s1").s2(12431234213123423l).build();
		ChildStruct c1 = (ChildStruct) JSONStructSerializer.fromJson(c0.toJson());
		assertEquals(c0, c1);
	}
	
	private SimpleTypes getSimpleTypes() {
		LocalDate d = LocalDate.now();
		LocalTime t = LocalTime.now();
		LocalDateTime dt = LocalDateTime.now();
		long ts = System.currentTimeMillis();
		UUID uuid = UUID.randomUUID();
		
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
	
	private MyStr1 getMyStr1() {
		Map<LocalDate, Boolean> m1 = ImmutableMap.of(LocalDate.parse("2016-08-29"), false, LocalDate.parse("2016-08-30"), true);
		Map<LocalDate, Boolean> m2 = ImmutableMap.of(LocalDate.parse("2016-08-31"), true);
		Map<LocalDate, Boolean> m3 = ImmutableMap.of();
		List<Map<LocalDate, Boolean>> l = new ArrayList<Map<LocalDate, Boolean>>();
		l.add(m1);
		l.add(m2);
		l.add(m3);
		
		return MyStr1.builder().lo(-1l).li(l).build();
	}
	
	private MyStr2 getMyStr2() {
		return MyStr2.builder().s("id").s1(getMyStr1()).build();
	}
	
	private ComplexTypes getComplexTypes() {
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
