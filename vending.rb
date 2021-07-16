module Function
  def waiting
    sleep 0.2
    puts ".."
    sleep 0.2
    puts "..."
    sleep 0.1
  end

  def enter
    puts "Enterを押してください"
    gets
  end

  def symbol
    puts "◆◆◆◆"
  end

  def menu_box
    @menu = { m00:'0.やめる',m01: '1.お金を入れる', m02: '2.商品を買う', m03: '3.お金払い戻し', m09: '9.管理者メニュー(*)',
      m11: '1.商品補充', m12: '2.商品追加', m13: '3.商品撤去', m14: '4.在庫確認', m15: '5.売上確認'}
  end

  def get_int
    @int = gets
    if @int =~ /^[0-9]+$/ then
      @int = @int.to_i
    else
      puts "不正な値が入力されました。もう一度入力してください"
      get_int
    end
  end
end

class Vending
include Function
    MONEY = [10, 50, 100, 500, 1000].freeze
  def initialize
    @slot_money ||= 0
    @sales_money ||= 0
    @stock ||= [["コーラ",120,5],["水",150,5],["レッドブル",200,5]]
    menu_box
  end

  def money
    @slot_money
  end

  def slot_money
    symbol
    puts "#{@menu[:m01]}"
    puts "お金を入れてください(10,50,100,500,1000)"
    money = gets.to_i
    if MONEY.include?(money)
      puts "#{money}円入れました"
      @slot_money += money
    else
      puts "はいんない"
    end
  end

  def buy
    symbol
    puts "#{@menu[:m02]}"
    puts "【投入金額：#{@slot_money}円】"
    stock_status
    puts "#{@menu[:m00]}"
    puts "どれを買いますか（番号を入力）"
    get_int
    number = @int
    case number
    when 0 then
      puts "購入をやめました"
    when (1..@stock.length) then
      if @stock[number-1][2] == 0 || @stock[number-1][1] > @slot_money #在庫がないか、お金が足りていない時
        puts "購入できません"
        waiting
        buy
      else
        puts "#{@stock[number-1][0]}を買いました"
        @stock[number-1][2] -= 1
        @slot_money -= @stock[number-1][1]
        @sales_money += @stock[number-1][1]
      end
    else
      puts "そこに商品はありません、入力し直してください"
      waiting
      buy
    end
  end

  def return_money
    symbol
    puts "おつりです#{@slot_money}円"
    puts "さようなら、また会いましょう"
    @slot_money = 0
    symbol
  end

  def drink_store
    symbol
    puts "#{@menu[:m11]}"
    if @stock.length < 1
      puts "商品がありません"
    else
      puts "追加したいドリンクの番号を選んでください"
      stock_status
      drink = gets.to_i
      if drink == 0
        puts "正しい入力をしてください。"
      else
        unless @stock.length < drink
          puts "#{@stock[drink-1][0]} が選択されました。"
          puts "値段は#{@stock[drink-1][1]}円で販売します。"
          puts "個数を入力してください。"
          number = gets.to_i
          if number == 0
            puts "正しい入力をしてください。"
            waiting
            drink_store
          else
            @stock[drink-1][2] += number.to_i
            puts "在庫を追加しました。#{@stock[drink-1][0]}の在庫数：#{@stock[drink-1][2]}本"
          end
        end
      end
    end
  end

  def new_stock
    symbol
    puts "#{@menu[:m12]}"
    puts "商品名を追加してください"
    name = gets.chomp
    puts "値段を入力してください"
    get_int
    price = @int
    puts "個数を入力してください"
    get_int
    stock = @int
    @stock << [name, price, stock]
    waiting
    puts "『#{name}』を『#{price}円』で『#{stock}本』追加しました。"
    puts "在庫を確認したい場合は#{@menu[:m14]}から。"
  end

  def remove_drink
    symbol
    puts "#{@menu[:m13]}"
    if @stock.length < 1
      puts "商品がありません"
    else
      puts "撤去したいドリンクの番号を選んでください"
      stock_status
      get_int
      drink = @int
      if @stock.length >= drink
        puts "#{@stock[drink-1][0]}を撤去しました。"
        @stock.delete_at(drink-1)
      else
        puts "選択した位置に商品がありません。もう一度やり直してください。"
      end
    end
  end

  def drink_menu
    symbol
    puts "#{@menu[:m14]}"
    stock_status
  end

  def sales
    symbol
    puts "#{@menu[:m15]}"
    puts "残金：#{@slot_money}円"
    puts "売上：#{@sales_money}円"
  end

  def stock_status
    @stock.each_with_index do |(name, price, stock), i|
      puts "商品#{i+1}:#{name}, 値段:#{price}円, 在庫数:#{stock}本,"
    end
  end
end

class Parent
  include Function
  def initialize
    @@vending ||= Vending.new
    menu_box
  end
end

class User < Parent
  def index
    waiting
    symbol
    puts "何か用ですか？(数字を入力してください)"
    puts "#{@menu[:m01]} #{@menu[:m02]}"
    puts "#{@menu[:m00]}"
    puts "【投入金額：#{@@vending.money}円】"
    get_int
    number = @int
    case number.to_i
    when 1 then
      waiting
      @@vending.slot_money
      index
    when 2 then
      waiting
      @@vending.buy
      index
    when 0 then
      @@vending.return_money
    else
      puts "その番号はありません"
      index
    end
  end
end

class Admin < Parent
  def admin_index
    symbol
    puts "#{@menu[:m09]}(数字を入力してください)"
    puts "#{@menu[:m11]} #{@menu[:m12]} #{@menu[:m13]}"
    puts "#{@menu[:m14]} #{@menu[:m15]}"
    puts "#{@menu[:m00]}"
    get_int
    number = @int
    waiting
    case number.to_i
    when 1 then
      @@vending.drink_store
      enter
      admin_index
    when 2 then
      @@vending.new_stock
      enter
      admin_index
    when 3 then
      @@vending.remove_drink
      enter
      admin_index
    when 4 then
      @@vending.drink_menu
      enter
      admin_index
    when 5 then
      @@vending.sales
      enter
      admin_index
    when 0 then
      symbol
      puts "さようなら"
      symbol
    end
  end
end

  # vm = Vending.new
  # vm.index
  # require '/Users/pc/workspace/80_pairpro/自動販売機/0716_hongo.rb'
