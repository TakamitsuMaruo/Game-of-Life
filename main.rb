require "dxruby"

LENGTH = 20 # これの2乗がセルの数。40くらいが限界
ALIVE = 1 # そのセルが生きている状態を 1 、死んでいる状態を 0 とする。
DEAD = 0
CELL = 20 # セルの一辺の長さ
MARGIN = CELL / 5 # セルとセルの隙間
WINDOW_LENGTH = LENGTH * ( CELL + MARGIN ) + MARGIN # ウィンドウの一辺の長さ

cur_cells = [] # 現在のセルの状態
next_cells = [] # 次の世代のセルの状態

# Array.new( LENGTH + 2 , Array.new( LENGTH + 2 , DEAD ) ) で初期化すると同じオブジェクトを指してしまうため
for i in 0...LENGTH+2

	cur_cells << []
	next_cells << []

end

# 全セルを死亡状態で初期化する。
for y in 0...LENGTH+2

	for x in 0...LENGTH+2

		cur_cells[y][x] = DEAD
		next_cells[y][x] = DEAD

	end

end


frame = 0 # ゲームが立ち上がってからのフレーム数のカウント
play = false # ゲームが動いているかどうかのフラグ
font = Font.new(LENGTH) # フォント。サイズは適当。

Window.width = WINDOW_LENGTH # ウィンドウの横幅
Window.height = WINDOW_LENGTH + 30 # ウィンドウの縦の長さ
Window.caption = "Conway's Game of Life" # ウィンドウのキャプション

Window.loop do
	
	Window.draw( 0 , 0 , Image.new( WINDOW_LENGTH , WINDOW_LENGTH , [118,118,118,255] ) ) # 背景画像

	for y in 1..LENGTH

		for x in 1..LENGTH

			# 各セルの描画
			Window.draw( ( CELL + MARGIN ) * x - CELL , ( CELL + MARGIN ) * y - CELL , Image.new( CELL , CELL , ( cur_cells[y][x] == ALIVE ? C_WHITE : C_BLACK ) ) )

		end

	end

	if ( Input.keyDown?( K_RIGHTARROW ) || play )

		if ( frame % 6 == 0 )

			frame += 1

			for y in 1..LENGTH

				sum_of_around = 0

				for x in 1..LENGTH

					sum_of_around = cur_cells[y-1][x-1] + cur_cells[y][x-1] + cur_cells[y+1][x-1] + cur_cells[y-1][x] + cur_cells[y+1][x] + cur_cells[y-1][x+1] + cur_cells[y][x+1] + cur_cells[y+1][x+1]

					# 生存判定
					if ( sum_of_around == 3 || ( sum_of_around == 2 && cur_cells[y][x] == ALIVE ) )
					
						next_cells[y][x] = ALIVE
					
					else
					
						next_cells[y][x] = DEAD
					
					end

				end

			end

			frame = 0

			for y in 1..LENGTH
			
				for x in 1..LENGTH

					# フィールドを更新
					cur_cells[y][x] = next_cells[y][x]
				
				end
			
			end

		end

	else

		if ( Input.mousePush?( M_LBUTTON ) )

			# クリックされたセルの生存/死亡を切り替える。
			cur_cells[( ( Input.mouse_y - MARGIN ) / ( CELL + MARGIN ) ) + 1][( ( Input.mouse_x - MARGIN ) / ( CELL + MARGIN ) ) + 1] ^= 1
			# 生存/死亡は1/0で管理されているため1との排他的論理和(XOR)をとると切り替えることができる。

		end

		if ( Input.keyPush?( K_DELETE ) )
			
			for y in 1..LENGTH

				for x in 1..LENGTH

					# 全セルを死亡状態にする。
					cur_cells[y][x] = DEAD

				end
			
			end
		
		end

	end

	# play も true/false で管理されているので true との排他的論理和(XOR)をとることで切り替えることができる。
	play ^= true if ( Input.keyPush?( K_SPACE ) )

	Window.drawFont( MARGIN , WINDOW_LENGTH + MARGIN * 2 , "#{play ? "Play" : "Pause"}(SPACEで切り替え)" , font )
	# a ? b : c 三項演算子。 a が真の場合 b を、偽の場合 c を返す。この場合 play が true なら "Play" を、 false なら "Pause" を返す。

	# Escapeキーが押されたら終了。
	exit if ( Input.keyPush?( K_ESCAPE ) )

end