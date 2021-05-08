(module
    (import "js" "memory" (memory 1))
    (import "js" "table" (table 1 funcref))
    (global $canvas_width (import "js" "canvas_width") (mut i32))
    (global $canvas_height (import "js" "canvas_height") (mut i32))
    (global $artwork_width (import "js" "artwork_width") (mut i32))
    (global $artwork_height (import "js" "artwork_height") (mut i32))
    (global $canvas_addr (import "js" "canvas_addr") (mut i32))
    (global $artwork_addr (import "js" "artwork_addr") (mut i32))
    (func $console_log (import "js" "console_log") (mut i32))
    (func $error_out_of_bounds (import "js" "error_out_of_bounds") (param i32) (param i32) (param i32))
    (func $random (import "js" "random")(param i32)(result i32))
    (func $calc_canvas_address (import "js" "calc_canvas_address")(param i32) (param i32) (result i32))
    (func calc_artwork_address (import "js" "clear_screen") (param i32))
    (func $draw_image (import "js" "draw_image") (param i32) (param i32) (param i32) (param i32) (param i32))
    (func $draw_artwork (import "js" "draw_artwork") (param i32)(param i32)(param i32)(param i32)(param i32)(param i32))

    (data offset(i32.const 0x600)) 
    "\00\00\01\00\02\00\00\03\00\04\00\05\00\06\00\07\00\08\00\09\00\0a\00\0b\00\0c\00\0d\00\0e\00\0f\00\1f\03\1f\04\1f\05\1f\06\1f\07\1f\08\1f\09\1f\0a\1f\0b\1f\0c\1f\0d\1f\0e\1f\0f\1f\10\1f\11\1f\12\1f\13\1f\14\1f\15\00\01\00\02\05\03\1f\04\1f\05\1f\06\1f\07\1f\08\1f\09\1f\0a\1f\0b\1f\0c\1f\0d\1f\0e\1f\0f\1f\10\1f\11\1f\12\1f\13\1f\14\1f\15\00\01\00\02\00\05\01\15\02\15\03\15\04\15\05\15\06\15\07\15\08\15\09\15\0a\15\0b\15\0c\15\0d\15\0e\15\0f\15\10\15\11\15\12\15\13\15\14\15\16\15\17\15\04\01\0f\02\0f\03\0f\04\0f\05\0f\06\0f\08\08\08\09\08\0a\08\07\07\0a\11\0a\12\0a\13\0a\14\0a\15\0a\16\0a\17\0a\18\0a\15\01\15\02\15\08\14\08\13\08\11\08\10\08\0f\07\0f\08\0f\09\0f\0a\0f\0b\0f\0c\0f\0d\0f\0e\0f\0f\0f\10\0f\11\0f\12\0b\0c\0b\0d\0b\0e\0b\0f")

    (data (offset (i32.const 0x200))
        "\90\00\00\00"
        "\80\00\00\00"
        "\00\00\00\00"
    )
    ;;returns 1 if the avatar will not collide left
    (func $collide_left (param $x i32)(param $y i32) (result i32)
        (local $addr i32)
        (local $counter i32)
        (local $future_x i32)
        (local.set $addr (i32.const 0x600))
        (local.set $counter (i32.const 0))
        (local.set $future_x (i32.add (local.get $x) (i32.const -16)))
        ;;
        block $done
            loop $repeat 
            (i32.ge_u (local.get $counter) (i32.const 186))
            br_if $done
            ;;
            (i32.eq (i32.mul (i32.load8_u (local.get $addr)) (i32.const 16))(local.get $future_x))
            if
                (i32.eq (i32.mul (i32.load8_u (i32.add (local.get $addr) (i32.const 1))) (i32.const 16)) (local.get $y))
                if
                    i32.const 0
                    return 
                end
            end
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
            br $repeat
            end $repeat 
        end $done 
        i32.const 1
    )

    (func $collide_right (param $x i32)(param $y i32) (result i32)
        (local $addr i32)
        (local $counter i32)
        (local $future_x i32)
        (local.set $addr (i32.const 0x600))
        (local.set $counter (i32.const 0))
        (local.set $future_x (i32.add (local.get $x) (i32.const 16)))
        ;;
        block $done
            loop $repeat 
            (i32.ge_u (local.get $counter) (i32.const 186))
            br_if $done
            ;;
            (i32.eq (i32.mul (i32.load8_u (i32.add (local.get $addr)(i32.const 1))) (i32.const 16))(local.get $y))
            if
                (i32.eq (i32.mul (i32.load8_u (local.get $addr)) (i32.const 16))(local.get $future_x))
                if
                    i32.const 0
                    return 
                end
            end
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
            br $repeat
            end $repeat 
        end $done 
        i32.const 1
    )

    (func $collide_up (param $x i32)(param $y i32) (result i32)
        (local $addr i32)
        (local $counter i32)
        (local $future_y`i32)
        (local.set $addr (i32.const 0x600))
        (local.set $counter (i32.const 0))
        (local.set $future_y (i32.add (local.get $y) (i32.const -16)))
        ;;
        block $done
            loop $repeat 
            (i32.ge_u (local.get $counter) (i32.const 186))
            br_if $done
            ;;
            (i32.eq (i32.mul (i32.load8_u (local.get $addr)) (i32.const 16)) (local.get $x))
            if
                (i32.eq (i32.mul (i32.load8_u (i32.add (local.get $addr)(i32.const 1))) (i32.const 16)) (local.get $future_y))
                if
                    i32.const 0
                    return 
                end
            end
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
            br $repeat
            end $repeat 
        end $done 
        i32.const 1
    )
    
    (func $collide_down (param $x i32)(param $y i32) (result i32)
        (local $addr i32)
        (local $counter i32)
        (local $future_y`i32)
        (local.set $addr (i32.const 0x600))
        (local.set $counter (i32.const 0))
        (local.set $future_y (i32.add (local.get $y) (i32.const 16)))
        ;;
        block $done
            loop $repeat 
            (i32.ge_u (local.get $counter) (i32.const 186))
            br_if $done
            ;;
            (i32.eq (i32.mul (i32.load8_u (local.get $addr))(i32.const 16)) (local.get $x))
            if
                (i32.eq (i32.mul (i32.load8_u (i32.add (local.get $addr) (i32.const 1))) (i32.const 16)) (local.get $future_y))
                if
                    i32.const 0
                    return 
                end
            end
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (local.set $addr (i32.add (local.get $addr) (i32.const 2)))
            br $repeat
            end $repeat 
        end $done 
        i32.const 1
    )
    
    (func $step_avatar (param $avatar_addr i32) (param $progress i32)
        (local $avatar_addr_x i32)
        (local $avatar_addr_y i32)
        (local $avatar_addr_prev_y i32)
        (local $avatar_artwork_width i32)
        (local $avatar_artwork_height i32)
        (local $avatar_artwork_frame i32)
        (local $avatar_artwork_x i32)
        (local $avatar_artwork_y i32)
        (local $avatar_movement i32)
        (local.set $avatar_addr_x (i32.add (local.get $avatar_addr) (i32.const 0)))
        (local.set $avatar_addr_y (i32.add (local.get $avatar_addr) (i32.const 4)))
        (local.set $avatar_addr_prev_y (i32.add (local.get $avatar_addr) (i32.const 8)))
        (local.set $avatar_artwork_width (i32.const 16))
        (local.set $avatar_artwork_height (i32.const 16))
        (local.set $avatar_movement (i32.const 16))
        ;;
        (local.set $avatar_artwork_y (i32.load (local.get $avatar_addr_prev_y)))
        (i32.load8_u (i32.const 37)) ;;left 
        if 
            (call $collide_left (i32.load (local.get $avatar_addr_x))(i32.load (local.get $avatar_addr_y)))
            if
                (i32.store (local.get $avatar_addr_x) (i32.add (i32.load (local.get $avatar_addr_x))(i32.mul (local.get $avatar_movement) (i32.const -1))))
            end
        end 
        (i32.load8_u (i32.const 38)) ;;up
        if  
            (i32.ge_u (i32.load (local.get $avatar_addr_y)) (local.get $avatar_movement))
            (call $collide_up (i32.load (local.get $avatar_addr_x))(i32.load (local.get $avatar_addr_y)))
            i32.and         
            if  
                (i32.store (local.get $avatar_addr_y) (i32.add (i32.load (local.get $avatar_addr_y)) (i32.mul (local.get $avatar_movement) (i32.const -1))))
            end
        end
        (i32.load8_u (i32.const 39)) ;;right 
        if
            (call $collide_right (i32.load (local.get $avatar_addr_x)) (i32.load (local.get $avatar_addr_y)))
            if  
                (i32.store (local.get $avatar_addr_x) (i32.add (i32.load (local.get $avatar_addr_x)) (local.get $avatar_movement)))
            end
        end
        (i32.load8_u (i32.const 40)) ;;down
        if
            (call $collide_down (i32.load (local.get $avatar_addr_x)) (i32.load (local.get $avatar_addr_y)))
            if 
                (i32.store (local.get $avatar_addr_y) (i32.add (i32.load (local.get $avatar_addr_y)) (local.get $avatar_movement)))
            end
        end
        (i32.store (local.get $avatar_addr_prev_y)(local.get $avatar_artwork_y))

        (local.set $avatar_artwork_frame (i32.and (i32.shr_u (local.get $progress) (i32.const 8))(i32.const 1)))
        (local.set $avatar_artwork_x (i32.const 0x00))
        (local.set $avatar_artwork_y (i32.const 0x00))

        ;;draw the avatar
        (call $draw_artwork
            (local.get $avatar_artwork_x)
            (local.get $avatar_artwork_y)
            (local.get $avatar_artwork_width)
            (local.get $avatar_artwork_height)
            (i32.load (local.get $avatar_addr_x))
            (i32.load (local.get $avatar_addr_y))
        )
    )
    
    (func $step (export "step")(param $progress i32))

        (local $adress i32)
        (local $counter i32)

        (call $clear_screen (i32.const 0xFF000000))
        i32.const 0x60
        local.set $adress
        i32.const 0
        local.set $counter
        block $done 
            loop $repeat
            (i32.ge_u (local.get $counter) (i32.const 186))
            br_if $done
            (call $draw_artwork
                (i32.const 488)
                (i32.const 869)
                (i32.const 16)
                (i32.const 16)
                (i32.mul (i32.const 16) (i32.load8_u (local.get $adress)))
                (i32.mul (i32.const 16) (i32.load8_u (i32.add (i32.const 1)(local.get $adress))))
            )
            (local.set $adress (i32.add (i32.const 2) (local.get $adress)))
            i32.const 1
            local.get $counter
            i32.add
            local.set $counter
            local.get $counter
            br_if $repeat
            end $repeat
        end $done

        (call $step_avatar (i32.const 0x200)(local.get $progress))
    )
)