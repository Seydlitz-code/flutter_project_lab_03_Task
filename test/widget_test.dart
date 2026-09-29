// Lab02 주문·할인 계산기(lib/main.dart) 동작 확인 테스트
// 실행: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project_lab_03_task/main.dart';

void main() {
  group('계산 함수', () {
    test('MenuItem category 기본값은 기타 (TODO 7-A)', () {
      const menu = MenuItem(name: '테스트', price: 1000);
      expect(menu.category, '기타');
    });

    test('lineTotal getter = 단가 × 수량 (TODO 8)', () {
      final order = OrderItem(
        menu: const MenuItem(name: '아메리카노', price: 3000),
        quantity: 3,
      );
      expect(order.lineTotal, 9000);
    });

    test('calculateSubtotal은 모든 주문 금액을 합산한다', () {
      final orders = [
        OrderItem(menu: const MenuItem(name: 'A', price: 3000), quantity: 2),
        OrderItem(menu: const MenuItem(name: 'B', price: 4500), quantity: 1),
      ];
      expect(calculateSubtotal(orders), 10500);
    });

    test('calculateDiscount: 회원 10% / 쿠폰 2,000원 / 대량 5% (TODO 4-B, 5-A, 6)', () {
      expect(calculateDiscount(subtotal: 10000, isMember: false), 0);
      expect(calculateDiscount(subtotal: 10000, isMember: true), 1000);
      // 쿠폰은 15,000원 이상일 때만 적용
      expect(
        calculateDiscount(subtotal: 14000, isMember: false, useCoupon: true),
        0,
      );
      expect(
        calculateDiscount(subtotal: 15000, isMember: false, useCoupon: true),
        2000,
      );
      // 30,000원 이상이면 대량 주문 5% 추가
      expect(calculateDiscount(subtotal: 30000, isMember: false), 1500);
      expect(
        calculateDiscount(subtotal: 30000, isMember: true, useCoupon: true),
        3000 + 2000 + 1500,
      );
    });

    test('calculateShippingFee: 0원 → 0, 25,000원 이상 → 0, 그 외 3,000 (TODO 3)', () {
      expect(calculateShippingFee(0), 0);
      expect(calculateShippingFee(1000), 3000);
      expect(calculateShippingFee(24999), 3000);
      expect(calculateShippingFee(25000), 0);
    });
  });

  group('화면', () {
    Future<void> pumpApp(WidgetTester tester) async {
      // ListView의 모든 카드가 한 화면에 그려지도록 테스트 화면을 세로로 늘린다.
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const OrderDiscountApp());
    }

    testWidgets('앱 실행 시 메뉴 3개와 초기 금액 0원이 표시된다 (TODO 1, 7-B)', (tester) async {
      await pumpApp(tester);

      expect(find.text('주문/할인 계산기'), findsOneWidget);
      expect(find.text('아메리카노'), findsOneWidget);
      expect(find.text('카페라떼'), findsOneWidget);
      expect(find.text('샌드위치'), findsOneWidget);
      expect(find.text('기타 | 3000원\n합계 0원'), findsOneWidget);
      expect(find.text('대량 주문 할인 5%'), findsOneWidget);
      expect(find.text('최종 결제 금액: 0원'), findsOneWidget);
    });

    testWidgets('+ 버튼을 누르면 금액이 다시 계산된다', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pump();

      expect(find.text('상품 금액: 3000원'), findsOneWidget);
      expect(find.text('배달비: 3000원'), findsOneWidget);
      expect(find.text('최종 결제 금액: 6000원'), findsOneWidget);
    });

    testWidgets('수량은 0~10으로 제한된다 (TODO 2)', (tester) async {
      await pumpApp(tester);

      final minus = find.byIcon(Icons.remove_circle_outline).first;
      final plus = find.byIcon(Icons.add_circle_outline).first;

      await tester.tap(minus);
      await tester.pump();
      expect(find.text('상품 금액: 0원'), findsOneWidget);

      for (var i = 0; i < 12; i++) {
        await tester.tap(plus);
        await tester.pump();
      }
      expect(find.text('10'), findsOneWidget);
      expect(find.text('상품 금액: 30000원'), findsOneWidget);
    });

    testWidgets('새로고침 버튼은 주문을 초기화한다', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(find.text('최종 결제 금액: 0원'), findsOneWidget);
    });
  });
}
