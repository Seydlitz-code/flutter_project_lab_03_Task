// 2주차 주문·할인 계산기 - 기능 확장 과제
// 확장 A: 카테고리별 쿠폰 할인 (음료 10%, 식사 15%)
// 확장 B: 카드사별 할인 정책 (KB / 신한 / 하나)
//         - 함수 타입, 함수 전달, 익명함수, => 표현 활용

import 'package:flutter/material.dart';

void main() {
  runApp(const OrderDiscountApp());
}

class MenuItem {
  final String name;
  final int price;
  final String category;

  const MenuItem({
    required this.name,
    required this.price,
    this.category = '기타',
  });
// [동작] 메뉴 이름, 단가, 카테고리를 저장하는 모델 클래스.
// -> category를 넘기지 않으면 '기타'로 초기화된다.
// -> 확장 A에서는 이 category 값으로 음료/식사 쿠폰 대상을 구분한다.
}

class OrderItem {
  final MenuItem menu;
  int quantity;

  OrderItem({
    required this.menu,
    this.quantity = 0,
  });

  int get lineTotal => menu.price * quantity;
// [동작] (단가 × 수량)을 돌려주는 getter.
// -> 확장 A의 카테고리 쿠폰 계산에서도 이 getter를 그대로 재사용한다.
}

// 주문 목록 전체의 상품 금액(subtotal)을 계산하는 top-level function.
int calculateSubtotal(List<OrderItem> orders) {
  var subtotal = 0;

  for (final order in orders) {
    subtotal += order.lineTotal;
  }

  return subtotal;
}
// [동작] 모든 주문 항목의 lineTotal을 누적해 할인 전 상품 금액을 반환한다.
// -> 카드 할인을 포함한 모든 할인 계산의 기준 금액이 된다.

// 기본 할인: 회원 할인 10% + 대량 주문 할인 5%
// (기존 2,000원 쿠폰은 카테고리 쿠폰으로 대체되어 제거)
int calculateDiscount({
  required int subtotal,
  required bool isMember,
}) {
  var discount = 0;

  if (isMember) {
    discount += (subtotal * 0.10).round();
  }

  if (subtotal >= 30000) {
    discount += (subtotal * 0.05).round();
  }

  return discount;
}
// [동작] 회원이면 subtotal의 10%, subtotal이 30,000원 이상이면 5%를 더한다.
// -> 기존 useCoupon 매개변수와 2,000원 쿠폰 로직은 확장 A로 대체되어 삭제했다.
// -> 결과는 계산 결과 영역의 '기본 할인'으로 표시된다.

// [확장 A] 카테고리 쿠폰 할인 계산 - 하나의 함수를 음료/식사에 재사용
int calculateCategoryCouponDiscount({
  required List<OrderItem> orders,
  required String category,
  double rate = 0.10,
}) {
  var categoryTotal = 0;

  for (final order in orders) {
    if (order.menu.category == category) {
      categoryTotal += order.lineTotal;
    }
  }

  return (categoryTotal * rate).round();
}
// [동작] 주문 목록을 for-in으로 돌면서 category가 일치하는 항목만 골라
// lineTotal을 누적하고, 그 합계에 rate(할인율)를 곱해 반올림한다.
// -> 음료용/식사용 함수를 따로 만들지 않고 category와 rate만 바꿔 호출한다.
// -> rate를 생략하면 기본값 0.10(10%)이 사용된다.
//    예) 음료 합계 10,500원 × 0.10 = 1,050원

// [확장 B] 모든 카드에 공통인 규칙을 처리하고, 카드사별 정책은 전달받아 실행
int applyCardDiscount(
    int subtotal,
    int Function(int) discountPolicy,
    ) {
  if (subtotal < 10000) {
    return 0;
  }

  final discount = discountPolicy(subtotal);

  if (discount > 5000) {
    return 5000;
  }
  return discount;
}
// [동작] 두 번째 매개변수 discountPolicy는 'int를 받아 int를 반환하는 함수'다.
// -> 1) subtotal이 10,000원 미만이면 정책을 실행하지 않고 0원을 반환한다.
// -> 2) 그 외에는 전달받은 정책 함수에 subtotal을 넣어 카드사별 할인액을 구한다.
// -> 3) 결과가 5,000원을 넘으면 5,000원으로 제한한다.
// -> 이 함수 안에서는 카드 이름을 전혀 검사하지 않는다.
//    '어떻게 할인할지'는 호출하는 쪽(build)이 함수로 넘겨준다.

int calculateShippingFee(int amountAfterDiscount) {
  if (amountAfterDiscount == 0) {
    return 0;
  }
  if (amountAfterDiscount >= 25000) {
    return 0;
  }
  return 3000;
}
// [동작] 할인 후 금액이 0원이면 0원, 25,000원 이상이면 무료,
// 그 외에는 3,000원을 반환한다. (기존 규칙 그대로 유지)

class OrderDiscountApp extends StatelessWidget {
  const OrderDiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final List<OrderItem> _orders = [
    OrderItem(
      menu: const MenuItem(
        name: '아메리카노',
        price: 3000,
        category: '음료',
      ),
    ),
    OrderItem(
      menu: const MenuItem(
        name: '카페라떼',
        price: 4500,
        category: '음료',
      ),
    ),
    OrderItem(
      menu: const MenuItem(
        name: '샌드위치',
        price: 6500,
        category: '식사',
      ),
    ),
  ];
  // [동작] 각 메뉴에 category를 지정한다.
  // -> 아메리카노·카페라떼는 '음료', 샌드위치는 '식사'이므로
  //    음료 쿠폰과 식사 쿠폰이 서로 다른 항목에만 적용된다.

  // 원본 State: 사용자의 조작으로만 바뀌는 값
  bool _isMember = false;
  bool _useDrinkCoupon = false;
  bool _useMealCoupon = false;
  String _selectedCard = 'KB';
  // [동작] 기존 _useCoupon 하나를 음료/식사 쿠폰 두 개의 bool로 나누고,
  // 현재 선택된 카드 이름을 String으로 저장한다.
  // -> 쿠폰 할인액, 카드 할인액, 총 할인액은 이 값들로 build()에서
  //    매번 계산할 수 있는 '파생값'이므로 State로 따로 저장하지 않는다.

  void _changeQuantity(OrderItem order, int difference) {
    setState(() {
      final nextQuantity = order.quantity + difference;

      if (nextQuantity < 0) {
        order.quantity = 0;
      } else if (nextQuantity > 10) {
        order.quantity = 10;
      } else {
        order.quantity = nextQuantity;
      }
    });
  }
  // [동작] 수량을 0~10 범위로 제한하며 변경한다. (기존 기능 유지)

  void _changeMember(bool value) {
    setState(() {
      _isMember = value;
    });
  }

  void _changeDrinkCoupon(bool value) {
    setState(() {
      _useDrinkCoupon = value;
    });
  }

  void _changeMealCoupon(bool value) {
    setState(() {
      _useMealCoupon = value;
    });
  }
  // [동작] 음료/식사 쿠폰 스위치를 누르면 각자의 bool State만 바꾼다.
  // -> 두 값은 서로 독립적이므로 동시에 켤 수 있다.
  // -> setState()로 build()가 다시 실행되며 쿠폰 할인액이 새로 계산된다.

  void _changeCard(String cardName) {
    setState(() {
      _selectedCard = cardName;
    });
  }
  // [동작] 카드 버튼을 누르면 선택 카드 이름을 '대입'한다.
  // -> 할인액을 더하는 것이 아니라 이름만 바꾸므로,
  //    같은 버튼을 여러 번 눌러도 할인이 누적되지 않는다.

  void _resetOrder() {
    setState(() {
      for (final order in _orders) {
        order.quantity = 0;
      }
      _isMember = false;
      _useDrinkCoupon = false;
      _useMealCoupon = false;
      _selectedCard = 'KB';
    });
  }
  // [동작] 수량과 회원 할인뿐 아니라 새로 추가한 두 쿠폰 상태와
  // 선택 카드도 초기값(OFF, 'KB')으로 되돌린다.

  @override
  Widget build(BuildContext context) {
    // ① subtotal 계산
    final subtotal = calculateSubtotal(_orders);

    // ② 기존 회원/대량 주문 할인 계산
    final basicDiscount = calculateDiscount(
      subtotal: subtotal,
      isMember: _isMember,
    );

    // ③ 카테고리 쿠폰 할인 계산
    final drinkCouponDiscount = _useDrinkCoupon
        ? calculateCategoryCouponDiscount(
      orders: _orders,
      category: '음료',
    )
        : 0;
    final mealCouponDiscount = _useMealCoupon
        ? calculateCategoryCouponDiscount(
      orders: _orders,
      category: '식사',
      rate: 0.15,
    )
        : 0;
    final couponDiscount = drinkCouponDiscount + mealCouponDiscount;
    // [동작] 같은 함수 calculateCategoryCouponDiscount를 두 번 호출한다.
    // -> 음료는 rate를 생략해 기본값 10%, 식사는 rate: 0.15로 15%를 적용한다.
    // -> 조건 ? A : B (삼항 연산자)로 쿠폰이 OFF면 0원을 사용한다.
    // -> 두 쿠폰이 모두 ON이면 couponDiscount에 두 할인액이 합산된다.

    // ④ switch로 카드 할인 정책 함수 선택 / ⑤ selectedCardPolicy에 익명함수 저장
    int Function(int) selectedCardPolicy;

    switch (_selectedCard) {
      case 'KB':
        selectedCardPolicy = (_) => 1500;
      case '신한':
        selectedCardPolicy = (amount) => (amount * 0.10).round();
      case '하나':
        selectedCardPolicy = (amount) {
          final units = amount ~/ 10000;
          return units * 1000;
        };
      default:
        selectedCardPolicy = (_) => 0;
    }
    // [동작] 변수 selectedCardPolicy의 타입은 int Function(int)이다.
    // -> 현재 선택된 카드에 맞는 '계산 방법(익명함수)'을 값처럼 대입한다.
    // -> KB: 금액과 무관하게 1,500원 → 매개변수를 쓰지 않으므로 _로 표기
    // -> 신한: 상품 금액의 10% → 한 줄 표현식이라 => 사용
    // -> 하나: ~/(정수 나눗셈)으로 1만원 단위 개수를 구해 × 1,000원
    //          → 두 줄이라 { return ...; } 형태의 익명함수 사용
    // -> 여기서는 함수를 '저장'만 하고 아직 실행하지 않는다.
    // -> Dart 3의 switch는 case가 자동으로 끝나므로 break가 필요 없다.

    // ⑥ applyCardDiscount 호출 / ⑦ 공통 규칙 + 카드사별 정책 실행
    final cardDiscount = applyCardDiscount(subtotal, selectedCardPolicy);
    // [동작] subtotal과 선택된 정책 함수를 함께 전달한다.
    // -> applyCardDiscount 내부에서 10,000원 미만 검사 → 정책 함수 실행 →
    //    5,000원 상한 적용 순서로 카드 할인액이 결정된다.
    // -> cardDiscount는 State가 아닌 파생값이라 build()마다 다시 계산된다.

    // ⑧ 전체 할인 금액 계산
    final totalDiscount = basicDiscount + couponDiscount + cardDiscount;

    // ⑨ 할인 후 금액 → 배송비 → 최종 결제 금액
    final amountAfterDiscount = subtotal - totalDiscount;
    final shippingFee = calculateShippingFee(amountAfterDiscount);
    final total = amountAfterDiscount + shippingFee;
    // [동작] 기본 할인 + 쿠폰 할인 + 카드 할인을 모두 합친 뒤
    // 기존 배송비 규칙을 할인 후 금액에 적용해 최종 금액을 구한다.

    // ⑩ 계산 결과를 UI에 반영
    final children = <Widget>[];

    children.add(
      const Text(
        'List, 조건문, 함수, named parameter, class, getter, 함수 전달을 앱에서 확인합니다.',
      ),
    );
    children.add(const SizedBox(height: 16));
    children.add(
      Text(
        '1. 메뉴 선택',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
    children.add(const SizedBox(height: 8));

    for (final order in _orders) {
      children.add(_buildMenuCard(order));
    }

    children.add(const SizedBox(height: 16));
    children.add(
      Text(
        '2. 할인 조건',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
    children.add(const SizedBox(height: 8));
    children.add(_buildDiscountCard());
    children.add(const SizedBox(height: 8));
    children.add(_buildCardDiscountCard(cardDiscount));
    children.add(const SizedBox(height: 16));
    children.add(
      Text(
        '3. 계산 결과',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
    children.add(const SizedBox(height: 8));
    children.add(
      _buildSummaryCard(
        subtotal: subtotal,
        basicDiscount: basicDiscount,
        drinkCouponDiscount: drinkCouponDiscount,
        mealCouponDiscount: mealCouponDiscount,
        couponDiscount: couponDiscount,
        cardDiscount: cardDiscount,
        totalDiscount: totalDiscount,
        shippingFee: shippingFee,
        total: total,
      ),
    );
    // [동작] 할인 조건 영역 아래에 카드사 할인 카드를 추가하고,
    // 계산 결과 카드에 새로 계산한 파생값들을 named parameter로 넘긴다.

    return Scaffold(
      appBar: AppBar(
        title: const Text('주문/할인 계산기 - 확장 과제'),
        actions: [
          IconButton(
            onPressed: _resetOrder,
            tooltip: '주문 초기화',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: children,
        ),
      ),
    );
  }

  Widget _buildMenuCard(OrderItem order) {
    return Card(
      child: ListTile(
        title: Text(order.menu.name),
        subtitle: Text(
          '${order.menu.category} | ${order.menu.price}원\n합계 ${order.lineTotal}원',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _changeQuantity(order, -1),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 28,
              child: Text(
                '${order.quantity}',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () => _changeQuantity(order, 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
  // [동작] 메뉴 한 줄을 그린다. '카테고리 | 단가'와 lineTotal을 표시한다.

  Widget _buildDiscountCard() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('회원 할인 10%'),
            value: _isMember,
            onChanged: _changeMember,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('음료 10% 할인 쿠폰'),
            subtitle: const Text('음료 카테고리 주문 금액에만 적용'),
            value: _useDrinkCoupon,
            onChanged: _changeDrinkCoupon,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('식사 15% 할인 쿠폰'),
            subtitle: const Text('식사 카테고리 주문 금액에만 적용'),
            value: _useMealCoupon,
            onChanged: _changeMealCoupon,
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('대량 주문 할인 5%'),
            subtitle: Text('상품 금액 30,000원 이상이면 자동 적용'),
          ),
        ],
      ),
    );
  }
  // [동작] 기존 2,000원 쿠폰 스위치를 음료/식사 쿠폰 스위치 두 개로 교체했다.
  // -> 각 스위치는 자기 bool State와 변경 함수에만 연결되어 서로 독립적이다.
  // -> 회원 할인 스위치와 대량 주문 안내는 기존 그대로 유지한다.

  Widget _buildCardButton(String cardName) {
    final isSelected = _selectedCard == cardName;

    if (isSelected) {
      return FilledButton(
        onPressed: () => _changeCard(cardName),
        child: Text(cardName),
      );
    }
    return OutlinedButton(
      onPressed: () => _changeCard(cardName),
      child: Text(cardName),
    );
  }
  // [동작] 카드 이름을 받아 버튼 하나를 만든다.
  // -> 현재 선택된 카드는 FilledButton(채워진 버튼), 나머지는
  //    OutlinedButton으로 그려 선택 상태를 눈으로 구분할 수 있게 한다.
  // -> 누르면 () => _changeCard(cardName) 익명함수가 실행된다.

  Widget _buildCardDiscountCard(int cardDiscount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카드사 할인',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text('공통: 상품 금액 10,000원 이상 / 최대 5,000원'),
            const Text('KB: 1,500원 / 신한: 10% / 하나: 1만원 단위마다 1,000원'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCardButton('KB'),
                _buildCardButton('신한'),
                _buildCardButton('하나'),
              ],
            ),
            const SizedBox(height: 12),
            Text('선택 카드: $_selectedCard'),
            Text('카드 할인: $cardDiscount원'),
          ],
        ),
      ),
    );
  }
  // [동작] 카드사 정책 안내, KB/신한/하나 버튼, 현재 선택 카드와
  // 카드 할인액을 한 카드 안에 표시한다.
  // -> cardDiscount는 build()에서 계산한 값을 매개변수로 받아 보여줄 뿐이다.

  Widget _buildSummaryCard({
    required int subtotal,
    required int basicDiscount,
    required int drinkCouponDiscount,
    required int mealCouponDiscount,
    required int couponDiscount,
    required int cardDiscount,
    required int totalDiscount,
    required int shippingFee,
    required int total,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('상품 금액: $subtotal원'),
            Text('기본 할인: $basicDiscount원'),
            Text('음료 쿠폰 할인: $drinkCouponDiscount원'),
            Text('식사 쿠폰 할인: $mealCouponDiscount원'),
            Text('카테고리 쿠폰 할인 합계: $couponDiscount원'),
            Text('카드 할인: $cardDiscount원'),
            Text('총 할인 금액: $totalDiscount원'),
            Text('배달비: $shippingFee원'),
            const Divider(),
            Text(
              '최종 결제 금액: $total원',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
// [동작] 기본 할인, 음료/식사 쿠폰 할인과 합계, 카드 할인,
// 총 할인 금액, 배달비, 최종 결제 금액을 순서대로 표시한다.
// -> 모두 build()에서 계산된 파생값을 named parameter로 받아 그린다.
}