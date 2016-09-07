package ru.weawer.ww.settings;

import static org.junit.Assert.assertEquals;

import java.nio.ByteBuffer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;
import com.google.common.primitives.Bytes;

import ru.weawer.ww.JSONStructSerializer;
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
		SimpleTypes t1 = JSONStructSerializer.fromJson(t0.toJson(), SimpleTypes.class);
		
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
		MyStr1 s1 = JSONStructSerializer.fromJson(s0.toJson(), MyStr1.class);
		
		assertEquals(s0.lo(), s1.lo());
		assertEquals(s0.li(), s1.li());
	}
	
	@Test
	public void testMyStr1Binary() {
		MyStr1 s0 = getMyStr1();		
		MyStr1 s1 = MyStr1.fromByteBuf(ByteBuffer.wrap(s0.toByteArray()));
		
		assertEquals(s0.lo(), s1.lo());
		assertEquals(s0.li(), s1.li());
	}
	
	@Test
	public void testMyStr2Json() {
		MyStr2 s0 = getMyStr2();
		MyStr2 s1 = JSONStructSerializer.fromJson(s0.toJson(), MyStr2.class);
		
		assertEquals(s0.s(), s1.s());
		assertEquals(s0.s1(), s1.s1());
	}
	
	@Test
	public void testMyStr2Binary() {
		MyStr2 s0 = getMyStr2();		
		MyStr2 s1 = MyStr2.fromByteBuf(ByteBuffer.wrap(s0.toByteArray()));
		
		assertEquals(s0.s(), s1.s());
		assertEquals(s0.s1(), s1.s1());
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

	public static void main(String[] args) {
		
		int [] a = new int[] { 128, 2, 3 };
		// Ну раз пост про ФП, то можно так: (Bytes - это com.google.common.primitives.Bytes из google-guava
		byte [] b = Bytes.toArray(IntStream.of(a).boxed().collect(Collectors.toList()));
		System.out.println(Arrays.toString(b));
		
		
		// Если по сети передавать, то ByteBuffer удобнейшая штука
		byte [] b1 = new byte[a.length * 4];
		ByteBuffer buf = ByteBuffer.wrap(b1);
		IntStream.of(a).forEach(i -> buf.putInt(i));		
		System.out.println(Arrays.toString(b1));
	}

}
